import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_providers.dart';
import '../../../services/google_drive_service.dart';

class DriveBackupScreen extends ConsumerStatefulWidget {
  const DriveBackupScreen({super.key});

  @override
  ConsumerState<DriveBackupScreen> createState() => _DriveBackupScreenState();
}

class _DriveBackupScreenState extends ConsumerState<DriveBackupScreen> {
  bool _isLoading = true;
  bool _isBackingUp = false;
  List<DriveBackupItem> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    final driveService = ref.read(googleDriveServiceProvider);
    final list = await driveService.listAllBackups();
    if (mounted) {
      setState(() {
        _backups = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleGoogleSignIn() async {
    final driveService = ref.read(googleDriveServiceProvider);
    if (driveService.isSignedIn) {
      await driveService.signOut();
    } else {
      await driveService.signIn();
    }
    setState(() {});
    await _loadBackups();
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    final messenger = ScaffoldMessenger.of(context);
    final driveService = ref.read(googleDriveServiceProvider);
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);

    try {
      final instId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();
      final payload = await db.exportFullBackupPayload(instId);

      final result = await driveService.createAndUploadBackup(
        payload: payload,
        appVersion: '1.0.0',
      );

      final isCloud = result['cloud_uploaded'] == true;
      final fileName = result['filename'] as String;
      final totalRecords = result['total_records'] as int;
      final fileSizeBytes = result['file_size_bytes'] as int;
      final checksum = result['checksum'] as String;
      final driveFileId = result['drive_file_id'] as String?;

      // Record in Supabase backup_history table
      await db.recordBackupHistory(
        institutionId: instId,
        initiatedBy: user?.id,
        filename: fileName,
        status: 'completed',
        driveFileId: driveFileId,
        checksum: checksum,
        recordCount: totalRecords,
        fileSizeBytes: fileSizeBytes,
      );

      await db.logAudit(
        action: 'BACKUP_CREATED',
        actorId: user?.id,
        entityType: 'backup',
        details: 'Created backup $fileName with $totalRecords records (${isCloud ? "Cloud Drive & Local" : "Local Storage"}).',
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isCloud
                ? 'Backup successfully saved to Google Drive and local storage ($totalRecords records)!'
                : 'Backup saved to device storage ($totalRecords records). Connect Google Drive for cloud sync.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      await _loadBackups();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Backup failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreBackup(DriveBackupItem item) async {
    final driveService = ref.read(googleDriveServiceProvider);
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);
    final messenger = ScaffoldMessenger.of(context);

    // 1. Download & parse
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying checksum & reading backup...'),
              ],
            ),
          ),
        ),
      ),
    );

    Map<String, dynamic>? backupData;
    try {
      backupData = await driveService.downloadAndValidateBackup(item);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to validate backup: $e'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (backupData == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not read backup file.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final metadata = backupData['metadata'] as Map<String, dynamic>? ?? {};
    final counts = metadata['record_counts'] as Map<String, dynamic>? ?? {};
    final payload = backupData['payload'] as Map<String, dynamic>? ?? {};

    // 2. Show Preview & Confirmation Dialog
    bool overwrite = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.settings_backup_restore_rounded, color: AppColors.royalBlue),
                  SizedBox(width: 8),
                  Text('Restore Backup', style: AppTextStyles.h3),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('File: ${item.name}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Timestamp: ${metadata["timestamp"] ?? "Unknown"}', style: AppTextStyles.caption),
                    Text('Total Records: ${metadata["total_records"] ?? 0}', style: AppTextStyles.bodyMedium),
                    const Divider(height: 24),
                    const Text('Payload Contents:', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    _countRow('Classes', counts['classes'] ?? 0),
                    _countRow('Subjects', counts['subjects'] ?? 0),
                    _countRow('Departments', counts['departments'] ?? 0),
                    _countRow('Academic Terms', counts['academic_terms'] ?? 0),
                    _countRow('Attendance Sessions', counts['attendance_sessions'] ?? 0),
                    _countRow('Attendance Records', counts['attendance_records'] ?? 0),
                    const Divider(height: 24),
                    const Text('Restore Mode:', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setDialogState(() => overwrite = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              !overwrite ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: !overwrite ? AppColors.royalBlue : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Merge & Update (Safe)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Keeps existing records and updates matching IDs', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setDialogState(() => overwrite = true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              overwrite ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: overwrite ? AppColors.error : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Complete Overwrite', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('Replaces current records with this backup', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: overwrite ? AppColors.error : AppColors.royalBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: const Text('Confirm Restore'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // 3. Execute Restore
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Restoring system database...'),
                ],
              ),
            ),
          ),
        ),
      );

      await db.restoreBackupPayload(payload, overwrite: overwrite);

      final instId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();
      await db.recordBackupHistory(
        institutionId: instId,
        initiatedBy: user?.id,
        filename: item.name,
        status: 'restored',
        driveFileId: item.isCloud ? item.id : null,
        recordCount: metadata['total_records'] ?? 0,
        fileSizeBytes: item.sizeBytes,
      );

      await db.logAudit(
        action: 'BACKUP_RESTORED',
        actorId: user?.id,
        entityType: 'backup',
        details: 'Restored backup ${item.name} (Overwrite: $overwrite).',
      );

      if (mounted) Navigator.pop(context); // Close restoring dialog
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Database restored successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Restore failed: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  static Widget _countRow(String label, dynamic count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text('$count', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveService = ref.watch(googleDriveServiceProvider);
    final user = driveService.currentUser;
    final isGoogleConnected = driveService.isSignedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Drive Backup & Restore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackups,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBackups,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Google Account Connectivity Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isGoogleConnected
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.neutralSlate.withValues(alpha: 0.2),
                                child: Icon(
                                  isGoogleConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                                  color: isGoogleConnected ? AppColors.success : AppColors.textSecondary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isGoogleConnected ? 'Google Drive Connected' : 'Google Drive Disconnected',
                                      style: AppTextStyles.h3,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isGoogleConnected
                                          ? (user?.email ?? 'Connected with drive.file scope')
                                          : 'Connect account to sync backups to Google Drive cloud folder.',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: _toggleGoogleSignIn,
                                icon: Icon(isGoogleConnected ? Icons.logout : Icons.login),
                                label: Text(isGoogleConnected ? 'Disconnect' : 'Connect Google Drive'),
                              ),
                              const Spacer(),
                              StatusBadge(
                                status: isGoogleConnected ? 'Cloud Active' : 'Local Only',
                                type: isGoogleConnected ? StatusType.success : StatusType.neutral,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Create Backup Action Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Instant Database Backup', style: AppTextStyles.h3),
                          const SizedBox(height: 6),
                          const Text(
                            'Generates a full JSON snapshot of classes, subjects, attendance sessions, and student records with SHA-256 integrity verification.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            text: 'Create Secure Backup Now',
                            icon: Icons.backup_rounded,
                            isLoading: _isBackingUp,
                            onPressed: _isBackingUp ? null : _createBackup,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available Backups Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Backups', style: AppTextStyles.h3),
                      Text('${_backups.length} snapshot(s)', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_backups.isEmpty)
                    const EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'No Backups Available',
                      message: 'Tap "Create Secure Backup Now" to capture your first database snapshot.',
                    )
                  else
                    ..._backups.map(
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: item.isCloud
                                ? AppColors.skyBlue.withValues(alpha: 0.1)
                                : AppColors.royalBlue.withValues(alpha: 0.1),
                            child: Icon(
                              item.isCloud ? Icons.cloud_outlined : Icons.smartphone_rounded,
                              color: item.isCloud ? AppColors.skyBlue : AppColors.royalBlue,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusBadge(
                                    status: item.isCloud ? 'Google Drive' : 'Device Storage',
                                    type: item.isCloud ? StatusType.info : StatusType.neutral,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(item.sizeBytes / 1024).toStringAsFixed(1)} KB',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Modified: ${DateFormat('yyyy-MM-dd HH:mm').format(item.modifiedTime)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          trailing: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.royalBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.restore_rounded, size: 16),
                            label: const Text('Restore'),
                            onPressed: () => _restoreBackup(item),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
