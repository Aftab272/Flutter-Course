import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_providers.dart';
import '../../../models/app_models.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  AttendanceSession? _activeSession;
  List<AttendanceRecord> _liveRoster = [];
  List<ClassModel> _assignedClasses = [];
  List<SubjectModel> _assignedSubjects = [];
  List<AttendanceSession> _pastSessions = [];

  String? _selectedClassId;
  String? _selectedSubjectId;
  int _sessionDurationMinutes = 10;
  int _lateThresholdMinutes = 5;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isLoading = false;
  bool _isLoadingRoster = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    final user = ref.read(authUserProvider);
    final db = ref.read(databaseServiceProvider);
    if (user == null) return;

    final instId = user.institutionId ?? await db.getOrCreateDefaultInstitution();
    final classes = await db.getClasses(instId);
    final subjects = await db.getAllSubjects(instId);
    final sessions = await db.getTeacherSessions(user.id);

    if (mounted) {
      setState(() {
        _assignedClasses = classes;
        _assignedSubjects = subjects;
        _pastSessions = sessions;
        if (classes.isNotEmpty) _selectedClassId = classes.first.id;
        if (subjects.isNotEmpty) _selectedSubjectId = subjects.first.id;
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_activeSession == null) return;

    _remainingTime = _activeSession!.expiresAt.difference(DateTime.now().toUtc());
    if (_remainingTime.isNegative) _remainingTime = Duration.zero;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _activeSession!.expiresAt.difference(DateTime.now().toUtc());
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
        });
      } else {
        setState(() {
          _remainingTime = remaining;
        });
      }
      // Poll roster every 5 seconds while session is active
      if (timer.tick % 5 == 0) {
        _refreshLiveRoster();
      }
    });
  }

  Future<void> _refreshLiveRoster() async {
    if (_activeSession == null || _isLoadingRoster) return;
    _isLoadingRoster = true;
    final db = ref.read(databaseServiceProvider);
    final records = await db.getSessionRecords(_activeSession!.id);
    if (mounted) {
      setState(() {
        _liveRoster = records;
        _isLoadingRoster = false;
      });
    }
  }

  Future<void> _generateQrSession() async {
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authUserProvider);
      final db = ref.read(databaseServiceProvider);
      if (user == null) return;

      final token = const Uuid().v4();
      final now = DateTime.now().toUtc();
      final expiresAt = now.add(Duration(minutes: _sessionDurationMinutes));

      final session = await db.createSession(
        subjectId: _selectedSubjectId!,
        teacherId: user.id,
        classId: _selectedClassId,
        qrToken: token,
        expiresAt: expiresAt,
        lateThresholdMinutes: _lateThresholdMinutes,
      );

      setState(() {
        _activeSession = session;
        _liveRoster = [];
      });

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating session: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rotateToken() async {
    if (_activeSession == null) return;
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseServiceProvider);
      final newToken = const Uuid().v4();
      final now = DateTime.now().toUtc();
      final newExpiresAt = now.add(Duration(minutes: _sessionDurationMinutes));

      // Close current and start rotated session
      await db.closeSession(_activeSession!.id);
      final rotatedSession = await db.createSession(
        subjectId: _activeSession!.subjectId,
        teacherId: _activeSession!.teacherId,
        classId: _activeSession!.classId,
        qrToken: newToken,
        expiresAt: newExpiresAt,
        lateThresholdMinutes: _lateThresholdMinutes,
      );

      setState(() {
        _activeSession = rotatedSession;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing token: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _closeSession() async {
    if (_activeSession == null) return;
    final db = ref.read(databaseServiceProvider);
    await db.closeSession(_activeSession!.id);
    _countdownTimer?.cancel();

    setState(() {
      _activeSession = null;
      _liveRoster = [];
    });
    _loadTeacherData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Attendance session concluded and closed successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Attendance Reports',
            onPressed: () => context.go('/admin/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTeacherData,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Teacher Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                            child: const Icon(Icons.co_present_rounded, size: 30, color: AppColors.royalBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Faculty Portal', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(user?.fullName ?? 'Faculty Member', style: AppTextStyles.h2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Session Setup vs Active Session
                  if (_activeSession == null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.qr_code_rounded, color: AppColors.royalBlue),
                                SizedBox(width: 10),
                                Text('Start Attendance Session', style: AppTextStyles.h3),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_assignedClasses.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: _selectedClassId,
                                decoration: const InputDecoration(labelText: 'Select Class & Section'),
                                items: _assignedClasses.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text('${c.name} ${c.section != null ? "(${c.section})" : ""}'),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedClassId = val),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (_assignedSubjects.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: _selectedSubjectId,
                                decoration: const InputDecoration(labelText: 'Select Subject'),
                                items: _assignedSubjects.map((s) {
                                  return DropdownMenuItem(
                                    value: s.id,
                                    child: Text('${s.name} (${s.code})'),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedSubjectId = val),
                              ),
                              const SizedBox(height: 14),
                            ],
                            // Duration & Late Threshold Sliders
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Validity: $_sessionDurationMinutes mins', style: AppTextStyles.bodyMedium),
                                      Slider(
                                        value: _sessionDurationMinutes.toDouble(),
                                        min: 1,
                                        max: 60,
                                        divisions: 12,
                                        label: '$_sessionDurationMinutes m',
                                        onChanged: (v) => setState(() => _sessionDurationMinutes = v.round()),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Late after: $_lateThresholdMinutes mins', style: AppTextStyles.bodyMedium),
                                      Slider(
                                        value: _lateThresholdMinutes.toDouble(),
                                        min: 1,
                                        max: 30,
                                        divisions: 6,
                                        label: '$_lateThresholdMinutes m',
                                        onChanged: (v) => setState(() => _lateThresholdMinutes = v.round()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            AppButton(
                              text: 'Generate Attendance QR Code',
                              onPressed: _generateQrSession,
                              isLoading: _isLoading,
                              icon: Icons.qr_code_2_rounded,
                              variant: AppButtonVariant.primary,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Active QR Session View
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.sensors_rounded, color: AppColors.success),
                                    SizedBox(width: 8),
                                    Text('Session Active', style: AppTextStyles.h3),
                                  ],
                                ),
                                // Countdown Display
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _remainingTime.inSeconds < 60 ? AppColors.errorLight : AppColors.skyBlueLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: _remainingTime.inSeconds < 60 ? AppColors.errorDark : AppColors.royalBlueDark,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${_remainingTime.inMinutes.toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _remainingTime.inSeconds < 60 ? AppColors.errorDark : AppColors.royalBlueDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // QR Code
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.borderLight, width: 2),
                                ),
                                child: QrImageView(
                                  data: _activeSession!.qrToken,
                                  version: QrVersions.auto,
                                  size: 220.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Late threshold applied after $_lateThresholdMinutes minutes',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _rotateToken,
                                    icon: const Icon(Icons.sync_rounded),
                                    label: const Text('Refresh Token'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _closeSession,
                                    icon: const Icon(Icons.stop_circle_outlined),
                                    label: const Text('Close Session'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Live Roster Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Live Scanned Roster (${_liveRoster.length})', style: AppTextStyles.h3),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshLiveRoster,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _liveRoster.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text('No students scanned yet. Waiting for attendance...'),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _liveRoster.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final record = _liveRoster[idx];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                                  title: Text('Student ID: ${record.studentId.substring(0, 8)}', style: AppTextStyles.bodyMedium),
                                  subtitle: Text(
                                    'Scanned at: ${record.scannedAt.toLocal().toString().substring(11, 19)}',
                                    style: AppTextStyles.caption,
                                  ),
                                  trailing: StatusBadge.fromString(record.status),
                                ),
                              );
                            },
                          ),
                  ],
                  const SizedBox(height: 28),

                  // Session History Section
                  const Text('Past Attendance Sessions', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  _pastSessions.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('No previous attendance sessions.')),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pastSessions.length > 5 ? 5 : _pastSessions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final session = _pastSessions[idx];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  session.isClosed ? Icons.check_circle_outline : Icons.sensors,
                                  color: session.isClosed ? AppColors.textSecondaryLight : AppColors.success,
                                ),
                                title: Text(
                                  'Session: ${session.createdAt.toString().substring(0, 10)}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                subtitle: Text(
                                  'Threshold: ${session.lateThresholdMinutes}m • Status: ${session.isClosed ? "Concluded" : "Active"}',
                                  style: AppTextStyles.caption,
                                ),
                                trailing: StatusBadge.fromString(session.isClosed ? 'Concluded' : 'Active'),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
