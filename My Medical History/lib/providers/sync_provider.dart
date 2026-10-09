import 'package:flutter/foundation.dart';
import '../services/drive_service.dart';

class SyncProvider extends ChangeNotifier {
  final DriveService _driveService = DriveService();
  bool isConnected = false;
  bool isSyncing = false;
  bool autoSync = true;
  String lastSync = 'Today, 10:32 AM';
  String syncStatus = 'Everything is up to date';

  Future<void> loadSyncStatus() async {
    isConnected = await _driveService.isConnected();
    final status = await _driveService.getSyncStatus();
    lastSync = status['last_sync']!;
    syncStatus = status['sync_status']!;
    notifyListeners();
  }

  Future<void> connectDrive() async {
    await _driveService.setConnected(true);
    isConnected = true;
    syncStatus = 'Everything is up to date';
    notifyListeners();
  }

  Future<void> syncNow() async {
    isSyncing = true;
    syncStatus = 'Syncing...';
    notifyListeners();

    bool success = await _driveService.syncNow();
    isSyncing = false;
    syncStatus = success ? 'Sync Successful' : 'Sync Failed';
    lastSync = 'Just now';
    notifyListeners();
  }

  void setAutoSync(bool enabled) {
    autoSync = enabled;
    notifyListeners();
  }
}
