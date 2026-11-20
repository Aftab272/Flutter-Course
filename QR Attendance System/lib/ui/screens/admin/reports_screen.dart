import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../services/export_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isLoading = true;
  List<AttendanceRecord> _allRecords = [];
  List<ClassModel> _classes = [];
  List<SubjectModel> _subjects = [];
  final Map<String, AttendanceSession> _sessionMap = {};

  String? _selectedClassId;
  String? _selectedSubjectId;
  String _selectedStatus = 'all'; // all, present, late
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);
    final instId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();

    final classes = await db.getClasses(instId);
    final subjects = await db.getAllSubjects(instId);

    // Fetch records from teacher sessions or student records
    final teacherSessions = user != null ? await db.getTeacherSessions(user.id) : <AttendanceSession>[];
    List<AttendanceRecord> records = [];

    _sessionMap.clear();
    if (teacherSessions.isNotEmpty) {
      for (final s in teacherSessions) {
        _sessionMap[s.id] = s;
        final recs = await db.getSessionRecords(s.id);
        records.addAll(recs);
      }
    } else {
      // If admin, fetch recent student attendance
      final allStudents = await db.getUsersByRole('student', institutionId: instId);
      for (final s in allStudents.take(20)) {
        final sRecs = await db.getStudentAttendance(s.id);
        records.addAll(sRecs);
      }
    }

    if (mounted) {
      setState(() {
        _classes = classes;
        _subjects = subjects;
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  List<AttendanceRecord> get _filteredRecords {
    return _allRecords.where((r) {
      if (_selectedStatus != 'all' && r.status.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_selectedClassId != null) {
        final s = _sessionMap[r.sessionId];
        if (s != null && s.classId != _selectedClassId) return false;
      }
      if (_selectedSubjectId != null) {
        final s = _sessionMap[r.sessionId];
        if (s != null && s.subjectId != _selectedSubjectId) return false;
      }
      if (_selectedDateRange != null) {
        final date = r.scannedAt;
        if (date.isBefore(_selectedDateRange!.start) ||
            date.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _exportPdf() async {
    final filtered = _filteredRecords;
    final filterText = 'Status: ${_selectedStatus.toUpperCase()}${_selectedDateRange != null ? " • Date: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}" : ""}';

    await ExportService.generateAndPrintPdfReport(
      records: filtered,
      title: 'Institutional Attendance Report',
      filterSummary: filterText,
    );
  }

  void _exportCsv() {
    final filtered = _filteredRecords;
    final csvData = ExportService.generateCsvReport(records: filtered);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CSV Export Ready', style: AppTextStyles.h3),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generated ${filtered.length} attendance rows:', style: AppTextStyles.caption),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvData,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Done'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;
    int presentCount = 0;
    int lateCount = 0;
    for (final r in filtered) {
      if (r.status.toLowerCase() == 'present') presentCount++;
      if (r.status.toLowerCase() == 'late') lateCount++;
    }
    final total = filtered.length;
    final pct = total > 0 ? ((presentCount + lateCount) / total * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports & Exports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Panel Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Filter Criteria', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Status Filter
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(labelText: 'Status'),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                                  DropdownMenuItem(value: 'present', child: Text('Present Only')),
                                  DropdownMenuItem(value: 'late', child: Text('Late Only')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedStatus = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Date Range Picker
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2030),
                                    initialDateRange: _selectedDateRange,
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDateRange = picked);
                                  }
                                },
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  _selectedDateRange == null
                                      ? 'Date Range'
                                      : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_classes.isNotEmpty || _subjects.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Class Filter
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  initialValue: _selectedClassId,
                                  decoration: const InputDecoration(labelText: 'Class (Optional)'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('All Classes')),
                                    ..._classes.map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          '${c.name} ${c.section ?? ""}'.trim(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _selectedClassId = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Subject Filter
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  initialValue: _selectedSubjectId,
                                  decoration: const InputDecoration(labelText: 'Subject (Optional)'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('All Subjects')),
                                    ..._subjects.map(
                                      (s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _selectedSubjectId = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Metrics Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _SummaryTile(label: 'Total Scans', value: '$total', color: AppColors.royalBlue),
                      const SizedBox(width: 10),
                      _SummaryTile(label: 'Present', value: '$presentCount', color: AppColors.success),
                      const SizedBox(width: 10),
                      _SummaryTile(label: 'Late', value: '$lateCount', color: AppColors.warning),
                      const SizedBox(width: 10),
                      _SummaryTile(label: 'Attendance %', value: '$pct%', color: AppColors.navyDark),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Attendance Records List
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'No Matching Records',
                          description: 'No attendance records match the selected filter criteria.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final r = filtered[idx];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: r.status == 'present'
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  child: Icon(
                                    r.status == 'present'
                                        ? Icons.check_circle_rounded
                                        : Icons.access_time_rounded,
                                    color: r.status == 'present'
                                        ? AppColors.successDark
                                        : AppColors.warningDark,
                                  ),
                                ),
                                title: Text('Student ID: ${r.studentId.substring(0, 8)}', style: AppTextStyles.bodyMedium),
                                subtitle: Text(
                                  'Scanned: ${r.scannedAt.toLocal().toString().substring(0, 16)}',
                                  style: AppTextStyles.caption,
                                ),
                                trailing: StatusBadge.fromString(r.status, isOfflineSynced: r.isOfflineSynced),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
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
      ),
    );
  }
}
