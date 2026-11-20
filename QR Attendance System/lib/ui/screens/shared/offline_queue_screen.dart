import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_providers.dart';

class OfflineQueueScreen extends ConsumerStatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  ConsumerState<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends ConsumerState<OfflineQueueScreen> {
  bool _isLoading = true;
  bool _isSyncing = false;
  List<Map<String, dynamic>> _queueItems = [];

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    final queueService = ref.read(offlineQueueServiceProvider);
    final items = await queueService.getPendingQueue();
    if (mounted) {
      setState(() {
        _queueItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerManualSync() async {
    setState(() => _isSyncing = true);
    final messenger = ScaffoldMessenger.of(context);
    final queueService = ref.read(offlineQueueServiceProvider);
    final db = ref.read(databaseServiceProvider);

    final result = await queueService.syncPendingRecords(customDb: db);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.total == 0
              ? 'No pending records to sync.'
              : 'Sync complete: ${result.synced} uploaded, ${result.failed} failed.',
        ),
        backgroundColor: result.failed > 0 ? AppColors.warning : AppColors.success,
      ),
    );

    await _loadQueue();
    if (mounted) setState(() => _isSyncing = false);
  }

  Future<void> _deleteItem(String id) async {
    final queueService = ref.read(offlineQueueServiceProvider);
    await queueService.removeFromQueue(id);
    await _loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    int pendingCount = 0;
    int failedCount = 0;
    for (final item in _queueItems) {
      final status = item['status'] as String? ?? 'pending';
      if (status == 'failed') {
        failedCount++;
      } else {
        pendingCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Attendance Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQueue,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Sync Overview Card
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
                                backgroundColor: pendingCount > 0
                                    ? AppColors.warning.withValues(alpha: 0.1)
                                    : AppColors.success.withValues(alpha: 0.1),
                                child: Icon(
                                  pendingCount > 0 ? Icons.sync_problem_rounded : Icons.cloud_done_rounded,
                                  color: pendingCount > 0 ? AppColors.warning : AppColors.success,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Offline Sync Engine', style: AppTextStyles.h3),
                                    const SizedBox(height: 2),
                                    Text(
                                      pendingCount > 0
                                          ? '$pendingCount scan(s) waiting for cloud upload.'
                                          : 'All local attendance records are synced with cloud.',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _miniStat(
                                  label: 'Pending Sync',
                                  value: '$pendingCount',
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _miniStat(
                                  label: 'Sync Failures',
                                  value: '$failedCount',
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            text: 'Sync Queue Now',
                            icon: Icons.sync_rounded,
                            isLoading: _isSyncing,
                            onPressed: _isSyncing || _queueItems.isEmpty ? null : _triggerManualSync,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Queued Items List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Queued Attendance Records', style: AppTextStyles.h3),
                      Text('${_queueItems.length} total', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_queueItems.isEmpty)
                    const EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Queue is Empty',
                      message: 'When offline scans occur, they will be safely queued here and synced automatically when connected.',
                    )
                  else
                    ..._queueItems.map(
                      (item) {
                        final id = item['id'] as String;
                        final sessionId = item['session_id'] as String;
                        final scannedAt = item['scanned_at'] as String;
                        final status = item['status'] as String? ?? 'pending';
                        final error = item['error_message'] as String?;
                        final attempts = item['attempts'] as int? ?? 0;
                        final isFailed = status == 'failed';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isFailed
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              child: Icon(
                                isFailed ? Icons.error_outline : Icons.cloud_upload_outlined,
                                color: isFailed ? AppColors.error : AppColors.warning,
                              ),
                            ),
                            title: Text(
                              'Session: ${sessionId.length > 12 ? "${sessionId.substring(0, 12)}..." : sessionId}',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusBadge(
                                      status: isFailed ? 'Failed' : 'Pending Upload',
                                      type: isFailed ? StatusType.error : StatusType.warning,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Attempts: $attempts', style: AppTextStyles.caption),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Scanned: ${scannedAt.length > 19 ? scannedAt.substring(0, 19).replaceAll("T", " ") : scannedAt}',
                                  style: AppTextStyles.caption,
                                ),
                                if (error != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: $error',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                              tooltip: 'Remove from queue',
                              onPressed: () => _deleteItem(id),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _miniStat({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
        ],
      ),
    );
  }
}
