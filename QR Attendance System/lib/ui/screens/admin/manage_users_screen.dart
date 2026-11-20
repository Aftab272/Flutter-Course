import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<UserProfile> _students = [];
  List<UserProfile> _teachers = [];
  List<ClassModel> _classes = [];
  List<SubjectModel> _subjects = [];
  String _institutionId = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);
    _institutionId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();

    final students = await db.getUsersByRole('student');
    final teachers = await db.getUsersByRole('teacher');
    final classes = await db.getClasses(_institutionId);
    final subjects = await db.getAllSubjects(_institutionId);

    if (mounted) {
      setState(() {
        _students = students;
        _teachers = teachers;
        _classes = classes;
        _subjects = subjects;
        _isLoading = false;
      });
    }
  }

  Future<void> _showEnrollDialog(UserProfile student) async {
    if (_classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a Class first.')),
      );
      return;
    }

    String selectedClassId = _classes.first.id;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Enroll ${student.fullName}', style: AppTextStyles.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select class to enroll student into:', style: AppTextStyles.caption),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedClassId,
                decoration: const InputDecoration(labelText: 'Target Class'),
                items: _classes.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} ${c.section != null ? "(${c.section})" : ""}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedClassId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogCtx);
                final db = ref.read(databaseServiceProvider);
                await db.enrollStudent(
                  classId: selectedClassId,
                  studentId: student.id,
                  institutionId: _institutionId,
                );
                messenger.showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('${student.fullName} successfully enrolled!'),
                  ),
                );
              },
              child: const Text('Confirm Enrollment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignTeacherDialog(UserProfile teacher) async {
    if (_classes.isEmpty || _subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure classes and subjects exist first.')),
      );
      return;
    }

    String selectedClassId = _classes.first.id;
    String selectedSubjectId = _subjects.first.id;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Assign ${teacher.fullName}', style: AppTextStyles.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedClassId,
                decoration: const InputDecoration(labelText: 'Assigned Class'),
                items: _classes.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} ${c.section != null ? "(${c.section})" : ""}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedClassId = val);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Assigned Subject'),
                items: _subjects.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.name} (${s.code})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedSubjectId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogCtx);
                final db = ref.read(databaseServiceProvider);
                await db.assignTeacher(
                  teacherId: teacher.id,
                  classId: selectedClassId,
                  subjectId: selectedSubjectId,
                  institutionId: _institutionId,
                );
                messenger.showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('${teacher.fullName} assigned successfully!'),
                  ),
                );
              },
              child: const Text('Assign Teacher'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.fullName.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          (s.studentIdNumber?.toLowerCase().contains(q) ?? false);
    }).toList();

    final filteredTeachers = _teachers.where((t) {
      final q = _searchQuery.toLowerCase();
      return t.fullName.toLowerCase().contains(q) || t.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: AppColors.skyBlueAccent,
          tabs: [
            Tab(text: 'Students (${_students.length})', icon: const Icon(Icons.school)),
            Tab(text: 'Teachers (${_teachers.length})', icon: const Icon(Icons.co_present)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, or roll number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Students Tab
                      filteredStudents.isEmpty
                          ? const EmptyStateWidget(
                              icon: Icons.people_outline,
                              title: 'No Students Found',
                              description: 'Registered students will appear here for class enrollment.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredStudents.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final student = filteredStudents[idx];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                                      child: const Icon(Icons.person, color: AppColors.royalBlue),
                                    ),
                                    title: Text(student.fullName, style: AppTextStyles.h3),
                                    subtitle: Text(
                                      '${student.studentIdNumber != null ? "ID: ${student.studentIdNumber} • " : ""}${student.email}',
                                      style: AppTextStyles.caption,
                                    ),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () => _showEnrollDialog(student),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Enroll'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      // Teachers Tab
                      filteredTeachers.isEmpty
                          ? const EmptyStateWidget(
                              icon: Icons.badge_outlined,
                              title: 'No Teachers Found',
                              description: 'Faculty members will appear here for course assignments.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredTeachers.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final teacher = filteredTeachers[idx];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.skyBlue.withValues(alpha: 0.1),
                                      child: const Icon(Icons.co_present_rounded, color: AppColors.skyBlue),
                                    ),
                                    title: Text(teacher.fullName, style: AppTextStyles.h3),
                                    subtitle: Text(teacher.email, style: AppTextStyles.caption),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () => _showAssignTeacherDialog(teacher),
                                      icon: const Icon(Icons.assignment_ind, size: 16),
                                      label: const Text('Assign'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.skyBlue,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
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
