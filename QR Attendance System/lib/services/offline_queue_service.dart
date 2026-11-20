import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_service.dart';

class SyncResult {
  final int total;
  final int synced;
  final int failed;
  final List<String> errors;

  SyncResult({
    required this.total,
    required this.synced,
    required this.failed,
    required this.errors,
  });
}

class OfflineQueueService {
  static Database? _database;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DatabaseService? _dbService;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance_queue.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_attendance (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            student_id TEXT NOT NULL,
            qr_token TEXT NOT NULL,
            scanned_at TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            error_message TEXT,
            attempts INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE offline_attendance ADD COLUMN status TEXT DEFAULT 'pending'");
            await db.execute("ALTER TABLE offline_attendance ADD COLUMN error_message TEXT");
            await db.execute("ALTER TABLE offline_attendance ADD COLUMN attempts INTEGER DEFAULT 0");
          } catch (_) {}
        }
      },
    );
  }

  /// Initialize background network listener for reactive auto-sync
  void initAutoSync(DatabaseService dbService) {
    _dbService = dbService;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && !_isSyncing) {
        syncPendingRecords();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> queueAttendance({
    required String id,
    required String sessionId,
    required String studentId,
    required String qrToken,
    required DateTime scannedAt,
  }) async {
    final db = await database;
    await db.insert(
      'offline_attendance',
      {
        'id': id,
        'session_id': sessionId,
        'student_id': studentId,
        'qr_token': qrToken,
        'scanned_at': scannedAt.toIso8601String(),
        'status': 'pending',
        'attempts': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingQueue() async {
    final db = await database;
    return await db.query(
      'offline_attendance',
      orderBy: 'scanned_at ASC',
    );
  }

  Future<void> removeFromQueue(String id) async {
    final db = await database;
    await db.delete(
      'offline_attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllQueue() async {
    final db = await database;
    await db.delete('offline_attendance');
  }

  Future<int> getQueueCount() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) FROM offline_attendance WHERE status = 'pending'");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Synchronize offline queue to Supabase cloud
  Future<SyncResult> syncPendingRecords({DatabaseService? customDb}) async {
    final db = customDb ?? _dbService;
    if (db == null) {
      return SyncResult(total: 0, synced: 0, failed: 0, errors: ['Database service not initialized']);
    }

    _isSyncing = true;
    final sqldb = await database;
    final pending = await sqldb.query(
      'offline_attendance',
      where: "status = 'pending'",
      orderBy: 'scanned_at ASC',
    );

    int synced = 0;
    int failed = 0;
    final List<String> errors = [];

    for (final item in pending) {
      final id = item['id'] as String;
      final sessionId = item['session_id'] as String;
      final studentId = item['student_id'] as String;
      final qrToken = item['qr_token'] as String;
      final scannedAtStr = item['scanned_at'] as String;
      final attempts = (item['attempts'] as int? ?? 0) + 1;
      final scannedAt = DateTime.tryParse(scannedAtStr) ?? DateTime.now();

      try {
        final result = await db.markAttendanceSecure(
          sessionId: sessionId,
          qrToken: qrToken,
          studentId: studentId,
          offlineTimestamp: scannedAt,
        );

        if (result['success'] == true) {
          // Accepted by server -> Remove from queue
          await removeFromQueue(id);
          synced++;
        } else {
          // Rejected by server (e.g. invalid token or session closed)
          final err = result['error'] ?? 'Attendance rejected by server';
          errors.add(err);
          failed++;
          await sqldb.update(
            'offline_attendance',
            {
              'status': 'failed',
              'error_message': err,
              'attempts': attempts,
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      } catch (e) {
        // Network or unexpected error during call -> keep pending but increment attempt count
        errors.add(e.toString());
        await sqldb.update(
          'offline_attendance',
          {
            'attempts': attempts,
            'error_message': e.toString(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }

    _isSyncing = false;
    return SyncResult(
      total: pending.length,
      synced: synced,
      failed: failed,
      errors: errors,
    );
  }
}
