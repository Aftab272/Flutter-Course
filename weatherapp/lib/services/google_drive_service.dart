import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../data/database_helper.dart';

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService {
  static final GoogleDriveService instance = GoogleDriveService._init();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleDriveService._init();

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // ignore
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Backup SQLite database to Google Drive
  Future<String> backupToDrive() async {
    try {
      var account = _googleSignIn.currentUser;
      if (account == null) {
        account = await signIn();
        if (account == null) {
          throw Exception('Google Sign-In required for backup.');
        }
      }

      final authHeaders = await account.authHeaders;
      final authenticatedClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticatedClient);

      // Export local database data as JSON
      final exportData = await DatabaseHelper.instance.exportAllData();
      final jsonString = jsonEncode(exportData);
      final bytes = utf8.encode(jsonString);

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
      final fileName = 'weather_app_backup_$dateStr.json';

      var driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.mimeType = 'application/json';
      driveFile.parents = ['appDataFolder']; // Store in app-specific hidden folder

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      final result = await driveApi.files.create(driveFile, uploadMedia: media);
      return result.id ?? 'Success';
    } catch (e) {
      throw Exception('Google Drive Backup failed: $e');
    }
  }

  // List available backups in Google Drive
  Future<List<drive.File>> listBackups() async {
    try {
      var account = _googleSignIn.currentUser;
      if (account == null) {
        account = await signIn();
        if (account == null) {
          throw Exception('Google Sign-In required to list backups.');
        }
      }

      final authHeaders = await account.authHeaders;
      final authenticatedClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticatedClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'weather_app_backup_'",
        orderBy: 'createdTime desc',
      );

      return fileList.files ?? [];
    } catch (e) {
      throw Exception('Failed to list backups from Google Drive: $e');
    }
  }

  // Restore SQLite database from Google Drive backup file ID
  Future<void> restoreFromDrive(String fileId) async {
    try {
      var account = _googleSignIn.currentUser;
      if (account == null) {
        throw Exception('Google Sign-In required for restore.');
      }

      final authHeaders = await account.authHeaders;
      final authenticatedClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticatedClient);

      drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      List<int> dataBytes = [];
      await for (var chunk in media.stream) {
        dataBytes.addAll(chunk);
      }

      final jsonString = utf8.decode(dataBytes);
      final decodedData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup schema version
      if (decodedData['schemaVersion'] == null || decodedData['schemaVersion'] != 1) {
        throw Exception('Unsupported or corrupted backup schema version.');
      }

      // Import into SQLite transaction
      await DatabaseHelper.instance.importAllData(decodedData);
    } catch (e) {
      throw Exception('Google Drive Restore failed: $e');
    }
  }
}
