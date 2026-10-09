import 'package:shared_preferences/shared_preferences.dart';

class DriveService {
  Future<bool> isConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('drive_connected') ?? false;
  }

  Future<void> setConnected(bool connected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('drive_connected', connected);
    await prefs.setString('last_sync', 'Today, 10:32 AM');
    await prefs.setString('sync_status', connected ? 'Everything is up to date' : 'Disconnected');
  }

  Future<Map<String, String>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'last_sync': prefs.getString('last_sync') ?? 'Never',
      'sync_status': prefs.getString('sync_status') ?? 'Normal',
      'storage_used': '14.2 MB',
    };
  }

  Future<bool> syncNow() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync', 'Just now');
    await prefs.setString('sync_status', 'Everything is up to date');
    return true;
  }

  Future<bool> restoreBackup() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
