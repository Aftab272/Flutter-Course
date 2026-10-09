import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/medical_provider.dart';
import '../../services/export_service.dart';
import '../backup/backup_sync_screen.dart';
import '../profile/profile_screen.dart';
import '../authentication/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  title: const Text('Profile'),
                  subtitle: const Text('John Doe • john.doe@gmail.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined, color: AppTheme.primaryColor),
                  title: const Text('Backup & Sync'),
                  subtitle: const Text('Google Drive connected'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSyncScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('SECURITY', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Card(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return SwitchListTile(
                  secondary: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  title: const Text('App Lock (PIN / Biometric)'),
                  subtitle: const Text('Require authentication on app start'),
                  value: settings.appLockEnabled,
                  onChanged: (val) {
                    settings.setAppLock(val);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('DATA', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined, color: AppTheme.primaryColor),
                  title: const Text('Export Medical History'),
                  subtitle: const Text('Generate PDF summary report'),
                  onTap: () async {
                    final provider = Provider.of<MedicalProvider>(context, listen: false);
                    final file = await ExportService.generateMedicalHistoryPdf(provider.visits, provider.doctors);
                    await ExportService.openExportedPdf(file);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_outlined, color: AppTheme.primaryColor),
                  title: const Text('Restore Backup'),
                  subtitle: const Text('Restore from Google Drive'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Restore Backup'),
                        content: const Text('Restoring will replace local records with cloud backup data. Proceed?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup restored successfully')));
                            },
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('APP', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                  title: Text('Notifications'),
                  subtitle: Text('Follow-up and medicine reminders'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
