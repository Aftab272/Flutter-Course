import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';

class ManageClassesScreen extends ConsumerStatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  ConsumerState<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends ConsumerState<ManageClassesScreen> {
  bool _isLoading = true;
  List<ClassModel> _classes = [];
  List<DepartmentModel> _departments = [];
  List<AcademicTermModel> _terms = [];
  String _institutionId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);
    _institutionId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();

    final classes = await db.getClasses(_institutionId);
    final depts = await db.getDepartments(_institutionId);
    final terms = await db.getAcademicTerms(_institutionId);

    if (mounted) {
      setState(() {
        _classes = classes;
        _departments = depts;
        _terms = terms;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddClassDialog() async {
    final nameCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();
    String? selectedDeptId = _departments.isNotEmpty ? _departments.first.id : null;
    String? selectedTermId = _terms.isNotEmpty ? _terms.first.id : null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Class & Section', style: AppTextStyles.h3),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Class / Program Name',
                        hintText: 'e.g. BS Computer Science',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: sectionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        hintText: 'e.g. Section A',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_departments.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedDeptId,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: _departments.map((d) {
                          return DropdownMenuItem(value: d.id, child: Text(d.name));
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedDeptId = val),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_terms.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedTermId,
                        decoration: const InputDecoration(labelText: 'Academic Term'),
                        items: _terms.map((t) {
                          return DropdownMenuItem(value: t.id, child: Text(t.name));
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedTermId = val),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogCtx);
                final db = ref.read(databaseServiceProvider);
                await db.createClass(
                  name: nameCtrl.text.trim(),
                  section: sectionCtrl.text.trim().isNotEmpty ? sectionCtrl.text.trim() : null,
                  institutionId: _institutionId,
                  departmentId: selectedDeptId,
                  academicTermId: selectedTermId,
                );
                _loadData();
              },
              child: const Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes & Sections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.class_outlined,
                  title: 'No Classes Created',
                  description: 'Create your first institutional class and section to start enrolling students.',
                  actionLabel: 'Add Class',
                  onAction: _showAddClassDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _classes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _classes[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.school_rounded, color: AppColors.royalBlue),
                        ),
                        title: Text(item.name, style: AppTextStyles.h3),
                        subtitle: Text(
                          item.section != null ? 'Section: ${item.section}' : 'No section assigned',
                          style: AppTextStyles.caption,
                        ),
                        trailing: StatusBadge.fromString(item.status),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassDialog,
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Class'),
      ),
    );
  }
}
