import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';

class ManageSubjectsScreen extends ConsumerStatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  ConsumerState<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends ConsumerState<ManageSubjectsScreen> {
  bool _isLoading = true;
  List<SubjectModel> _subjects = [];
  List<ClassModel> _classes = [];
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

    final subjects = await db.getAllSubjects(_institutionId);
    final classes = await db.getClasses(_institutionId);

    if (mounted) {
      setState(() {
        _subjects = subjects;
        _classes = classes;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddSubjectDialog() async {
    if (_classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create at least one Class first before creating Subjects.')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    String selectedClassId = _classes.first.id;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Subject', style: AppTextStyles.h3),
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
                        labelText: 'Subject Name',
                        hintText: 'e.g. Data Structures & Algorithms',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subject Code',
                        hintText: 'e.g. CS-201',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
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
                await db.createSubject(
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim().toUpperCase(),
                  classId: selectedClassId,
                  institutionId: _institutionId,
                );
                _loadData();
              },
              child: const Text('Create Subject'),
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
        title: const Text('Manage Subjects'),
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
          : _subjects.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.menu_book_outlined,
                  title: 'No Subjects Added',
                  description: 'Add courses and subjects to your institutional curriculum.',
                  actionLabel: 'Add Subject',
                  onAction: _showAddSubjectDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _subjects[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.book_outlined, color: AppColors.skyBlue),
                        ),
                        title: Text(item.name, style: AppTextStyles.h3),
                        subtitle: Text(
                          'Code: ${item.code}',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: StatusBadge.fromString(item.status),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Subject'),
      ),
    );
  }
}
