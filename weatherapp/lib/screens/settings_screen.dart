import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';
import '../data/database_helper.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSignedIn = false;
  String? _userEmail;
  bool _isLoading = false;
  String _statusMessage = '';
  List<dynamic> _backups = [];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final signedIn = await GoogleDriveService.instance.isSignedIn();
    final account = GoogleDriveService.instance.currentUser;
    setState(() {
      _isSignedIn = signedIn;
      _userEmail = account?.email;
    });
    if (signedIn) {
      _loadBackups();
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await GoogleDriveService.instance.signIn();
      setState(() {
        _isSignedIn = account != null;
        _userEmail = account?.email;
        _isLoading = false;
        _statusMessage = account != null ? 'Signed in successfully!' : 'Sign-in cancelled.';
      });
      if (account != null) {
        _loadBackups();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Sign-in error: $e';
      });
    }
  }

  Future<void> _signOut() async {
    await GoogleDriveService.instance.signOut();
    setState(() {
      _isSignedIn = false;
      _userEmail = null;
      _backups = [];
      _statusMessage = 'Signed out of Google account.';
    });
  }

  Future<void> _backup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Backing up to Google Drive...';
    });
    try {
      final fileId = await GoogleDriveService.instance.backupToDrive();
      setState(() {
        _isLoading = false;
        _statusMessage = 'Backup completed successfully! (ID: ${fileId.substring(0, 8)}...)';
      });
      await DatabaseHelper.instance.saveSetting('last_backup_time', DateTime.now().toIso8601String());
      _loadBackups();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Backup failed: $e';
      });
    }
  }

  Future<void> _loadBackups() async {
    try {
      final files = await GoogleDriveService.instance.listBackups();
      setState(() {
        _backups = files;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _restore(String fileId) async {
    // Confirm before restoring
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text('Restoring will replace your current local settings, saved cities, and cache with the backup data. Proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Restoring from Google Drive...';
    });

    try {
      await GoogleDriveService.instance.restoreFromDrive(fileId);
      setState(() {
        _isLoading = false;
        _statusMessage = 'Restore completed successfully! Restart app to refresh view.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Restore failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Backup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('Celsius (°C)'),
              subtitle: const Text('Use metric temperature units'),
              value: true,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(height: 24),
          const Text('Google Drive Cloud Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          const SizedBox(height: 4),
          const Text(
            'Securely backup your saved cities, recent searches, and settings to your private Google Drive App Folder.',
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_sync, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSignedIn ? 'Connected Account' : 'Not Connected',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _userEmail ?? 'Sign in with Google to enable cloud backup',
                              style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isSignedIn)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _signIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Connect Google Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _backup,
                                icon: const Icon(Icons.upload),
                                label: const Text('Backup Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _signOut,
                                icon: const Icon(Icons.logout),
                                label: const Text('Disconnect'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isSignedIn && _backups.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Available Google Drive Backups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._backups.map((file) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.backup, color: AppTheme.primary),
                    title: Text(file.name ?? 'Backup file', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Created: ${file.createdTime ?? 'Unknown'}', style: const TextStyle(fontSize: 11)),
                    trailing: ElevatedButton(
                      onPressed: _isLoading ? null : () => _restore(file.id!),
                      child: const Text('Restore'),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
