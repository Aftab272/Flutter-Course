import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class DriveBackupItem {
  final String id;
  final String name;
  final int sizeBytes;
  final DateTime modifiedTime;
  final bool isCloud;
  final String? localPath;

  DriveBackupItem({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.modifiedTime,
    required this.isCloud,
    this.localPath,
  });
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  GoogleDriveService() {
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _currentUser = event.user;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _currentUser = null;
      }
    });
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        await _googleSignIn.initialize();
        _isInitialized = true;
      } catch (_) {}
    }
  }

  // ================= Authentication =================
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      _currentUser = await _googleSignIn.authenticate(
        scopeHint: [drive.DriveApi.driveFileScope],
      );
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (_) {}
  }

  // Helper for authenticated HTTP calls to Drive API
  Future<drive.DriveApi?> _getDriveApi() async {
    await _ensureInitialized();
    GoogleSignInAccount? account = _currentUser;
    if (account == null) {
      try {
        account = await _googleSignIn.attemptLightweightAuthentication();
      } catch (_) {}
    }
    if (account == null) return null;
    _currentUser = account;

    final headers = await account.authorizationClient.authorizationHeaders(
      [drive.DriveApi.driveFileScope],
      promptIfNecessary: true,
    );
    if (headers == null) return null;

    final client = _GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  // ================= Checksum & Schema Helpers =================
  static String calculateChecksum(Map<String, dynamic> payload) {
    final payloadStr = jsonEncode(payload);
    return sha256.convert(utf8.encode(payloadStr)).toString();
  }

  static bool verifyChecksum(Map<String, dynamic> backupData) {
    final meta = backupData['metadata'] as Map<String, dynamic>?;
    final payload = backupData['payload'] as Map<String, dynamic>?;
    if (meta == null || payload == null) return false;
    final expectedChecksum = meta['checksum'] as String?;
    final actualChecksum = calculateChecksum(payload);
    return expectedChecksum == actualChecksum;
  }

  // ================= Folder Management =================
  Future<String?> _getOrCreateDriveFolder(drive.DriveApi driveApi) async {
    try {
      final list = await driveApi.files.list(
        q: "mimeType = 'application/vnd.google-apps.folder' and name = 'QR_Attendance_Backups' and trashed = false",
        spaces: 'drive',
      );

      if (list.files != null && list.files!.isNotEmpty) {
        return list.files!.first.id;
      }

      final folderMetadata = drive.File()
        ..name = 'QR_Attendance_Backups'
        ..mimeType = 'application/vnd.google-apps.folder';
      final folder = await driveApi.files.create(folderMetadata);
      return folder.id;
    } catch (_) {
      return null;
    }
  }

  // ================= Upload Backup =================
  Future<Map<String, dynamic>> createAndUploadBackup({
    required Map<String, dynamic> payload,
    required String appVersion,
  }) async {
    // 1. Build Metadata
    final checksum = calculateChecksum(payload);
    final now = DateTime.now().toUtc();
    final fileName = 'qr_attendance_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.json';

    int countDepts = (payload['departments'] as List?)?.length ?? 0;
    int countTerms = (payload['academic_terms'] as List?)?.length ?? 0;
    int countClasses = (payload['classes'] as List?)?.length ?? 0;
    int countSubjects = (payload['subjects'] as List?)?.length ?? 0;
    int countSessions = (payload['attendance_sessions'] as List?)?.length ?? 0;
    int countRecords = (payload['attendance_records'] as List?)?.length ?? 0;
    int countLogs = (payload['audit_logs'] as List?)?.length ?? 0;
    final totalRecords = countDepts + countTerms + countClasses + countSubjects + countSessions + countRecords + countLogs;

    final fullData = {
      'metadata': {
        'app_name': 'QR Attendance System',
        'publisher': 'Creative Stack Agency',
        'app_version': appVersion,
        'schema_version': '1.0',
        'timestamp': now.toIso8601String(),
        'checksum': checksum,
        'total_records': totalRecords,
        'record_counts': {
          'departments': countDepts,
          'academic_terms': countTerms,
          'classes': countClasses,
          'subjects': countSubjects,
          'attendance_sessions': countSessions,
          'attendance_records': countRecords,
          'audit_logs': countLogs,
        },
      },
      'payload': payload,
    };

    final jsonString = jsonEncode(fullData);
    final bytes = utf8.encode(jsonString);

    // 2. Always persist a local copy for device safety and offline recovery
    String? localSavedPath;
    try {
      final dbPath = await getDatabasesPath();
      final backupDir = Directory('$dbPath/qr_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final localFile = File('${backupDir.path}/$fileName');
      await localFile.writeAsString(jsonString);
      localSavedPath = localFile.path;
    } catch (_) {}

    // 3. Upload to Google Drive if signed in (with 3-attempt exponential backoff)
    String? driveFileId;
    bool cloudUploaded = false;
    final driveApi = await _getDriveApi();
    if (driveApi != null) {
      final folderId = await _getOrCreateDriveFolder(driveApi);
      if (folderId != null) {
        int attempts = 0;
        while (attempts < 3) {
          attempts++;
          try {
            final driveFile = drive.File()
              ..name = fileName
              ..parents = [folderId];
            final media = drive.Media(
              Stream.value(bytes),
              bytes.length,
            );
            final uploaded = await driveApi.files.create(driveFile, uploadMedia: media);
            driveFileId = uploaded.id;
            cloudUploaded = true;
            break;
          } catch (e) {
            if (attempts >= 3) break;
            await Future.delayed(Duration(milliseconds: 500 * (1 << attempts)));
          }
        }
      }
    }

    return {
      'filename': fileName,
      'checksum': checksum,
      'total_records': totalRecords,
      'file_size_bytes': bytes.length,
      'cloud_uploaded': cloudUploaded,
      'drive_file_id': driveFileId,
      'local_saved_path': localSavedPath,
      'full_data': fullData,
    };
  }

  // ================= List Backups (Cloud & Local) =================
  Future<List<DriveBackupItem>> listAllBackups() async {
    final List<DriveBackupItem> items = [];

    // 1. Fetch Cloud Backups if logged in
    try {
      final driveApi = await _getDriveApi();
      if (driveApi != null) {
        final folderId = await _getOrCreateDriveFolder(driveApi);
        if (folderId != null) {
          final res = await driveApi.files.list(
            q: "'$folderId' in parents and trashed = false",
            $fields: 'files(id, name, size, modifiedTime, createdTime)',
            orderBy: 'createdTime desc',
          );
          if (res.files != null) {
            for (final f in res.files!) {
              if (f.name != null && f.name!.startsWith('qr_attendance_backup')) {
                items.add(
                  DriveBackupItem(
                    id: f.id ?? '',
                    name: f.name ?? 'Unnamed Backup',
                    sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
                    modifiedTime: f.createdTime ?? DateTime.now(),
                    isCloud: true,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (_) {}

    // 2. Fetch Local Backups
    try {
      final dbPath = await getDatabasesPath();
      final backupDir = Directory('$dbPath/qr_backups');
      if (await backupDir.exists()) {
        final files = backupDir.listSync().whereType<File>();
        for (final f in files) {
          final name = f.uri.pathSegments.last;
          if (name.startsWith('qr_attendance_backup')) {
            final stat = await f.stat();
            items.add(
              DriveBackupItem(
                id: f.path,
                name: name,
                sizeBytes: stat.size,
                modifiedTime: stat.modified,
                isCloud: false,
                localPath: f.path,
              ),
            );
          }
        }
      }
    } catch (_) {}

    // Sort descending by modified date
    items.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    return items;
  }

  // ================= Download & Parse Backup =================
  Future<Map<String, dynamic>?> downloadAndValidateBackup(DriveBackupItem item) async {
    String? jsonContent;

    if (item.isCloud) {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      try {
        final drive.Media media = await driveApi.files.get(
          item.id,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final chunks = <int>[];
        await for (final chunk in media.stream) {
          chunks.addAll(chunk);
        }
        jsonContent = utf8.decode(chunks);
      } catch (_) {
        return null;
      }
    } else if (item.localPath != null) {
      try {
        final file = File(item.localPath!);
        if (await file.exists()) {
          jsonContent = await file.readAsString();
        }
      } catch (_) {
        return null;
      }
    }

    if (jsonContent == null) return null;

    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;
      // Validate schema and checksum
      final isValid = verifyChecksum(data);
      if (!isValid) {
        throw Exception('Backup checksum mismatch. File may be corrupted.');
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }
}

// Client wrapper for OAuth Bearer token
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
