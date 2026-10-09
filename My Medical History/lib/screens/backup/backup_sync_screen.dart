import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sync_provider.dart';

class BackupSyncScreen extends StatelessWidget {
  const BackupSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Sync'),
      ),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_sync, size: 64, color: AppTheme.primaryColor),
                        const SizedBox(height: 16),
                        const Text('Google Drive Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(syncProvider.isConnected ? 'Connected' : 'Disconnected', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Last Sync:', style: TextStyle(color: AppTheme.textSecondary)),
                            Text(syncProvider.lastSync, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sync Status:', style: TextStyle(color: AppTheme.textSecondary)),
                            Text(syncProvider.syncStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: syncProvider.isSyncing
                      ? null
                      : () async {
                          await syncProvider.syncNow();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(syncProvider.syncStatus)),
                            );
                          }
                        },
                  icon: syncProvider.isSyncing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.sync),
                  label: Text(syncProvider.isSyncing ? 'Syncing...' : 'Sync Now'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  subtitle: const Text('Automatically sync changes in background'),
                  value: syncProvider.autoSync,
                  onChanged: (val) => syncProvider.setAutoSync(val),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
