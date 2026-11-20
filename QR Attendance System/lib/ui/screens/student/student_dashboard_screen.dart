import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_providers.dart';
import '../../../models/app_models.dart';
import 'scan_qr_screen.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  bool _isLoading = true;
  List<AttendanceRecord> _records = [];
  int _presentCount = 0;
  int _lateCount = 0;
  int _totalSessions = 0;
  double _attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    final user = ref.read(authUserProvider);
    final db = ref.read(databaseServiceProvider);
    if (user == null) return;

    final records = await db.getStudentAttendance(user.id);

    int present = 0;
    int late = 0;
    for (final r in records) {
      if (r.status.toLowerCase() == 'present') {
        present++;
      } else if (r.status.toLowerCase() == 'late') {
        late++;
      }
    }

    final total = records.length;
    final pct = total > 0 ? ((present + late) / total) * 100 : 0.0;

    if (mounted) {
      setState(() {
        _records = records;
        _presentCount = present;
        _lateCount = late;
        _totalSessions = total;
        _attendancePercentage = pct;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_problem_outlined),
            tooltip: 'Offline Queue',
            onPressed: () => context.go('/offline-queue'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudentData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Student Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                        child: const Icon(Icons.school_rounded, size: 32, color: AppColors.royalBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.studentIdNumber != null
                                  ? 'Roll No: ${user!.studentIdNumber}'
                                  : 'Enrolled Student',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(user?.fullName ?? 'Student', style: AppTextStyles.h2),
                            Text(user?.email ?? '', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Quick Scan Action Banner
              Card(
                color: isDark ? AppColors.surfaceDark : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 48, color: AppColors.royalBlue),
                      const SizedBox(height: 10),
                      const Text('Ready for Class Attendance?', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Scan your teacher’s active QR code on the lecture screen.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        text: 'Open QR Scanner',
                        icon: Icons.camera_alt_outlined,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                          );
                          _loadStudentData();
                        },
                        variant: AppButtonVariant.primary,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Attendance Statistics Overview (Part G)
              const Text('Attendance Metrics', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Overall %',
                      value: '${_attendancePercentage.toStringAsFixed(1)}%',
                      icon: Icons.pie_chart_outline_rounded,
                      color: _attendancePercentage >= 75 ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Present',
                      value: '$_presentCount',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Late',
                      value: '$_lateCount',
                      icon: Icons.access_time,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Total Sessions',
                      value: '$_totalSessions',
                      icon: Icons.event_note_outlined,
                      color: AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Attendance History List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Attendance Log', style: AppTextStyles.h3),
                  TextButton.icon(
                    onPressed: _loadStudentData,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _records.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.history_edu_outlined,
                          title: 'No Records Yet',
                          description: 'Attendance records will appear here after you scan your classes.',
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _records.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final rec = _records[idx];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: rec.status == 'present'
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  child: Icon(
                                    rec.status == 'present'
                                        ? Icons.check_circle_rounded
                                        : Icons.access_time_filled_rounded,
                                    color: rec.status == 'present'
                                        ? AppColors.successDark
                                        : AppColors.warningDark,
                                  ),
                                ),
                                title: Text(
                                  'Session: ${rec.sessionId.substring(0, 8)}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                subtitle: Text(
                                  'Date: ${rec.scannedAt.toLocal().toString().substring(0, 16)}',
                                  style: AppTextStyles.caption,
                                ),
                                trailing: StatusBadge.fromString(rec.status, isOfflineSynced: rec.isOfflineSynced),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
