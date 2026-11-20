import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';

class ManageDepartmentsScreen extends ConsumerStatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  ConsumerState<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends ConsumerState<ManageDepartmentsScreen> {
  bool _isLoading = true;
  List<DepartmentModel> _departments = [];
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

    final depts = await db.getDepartments(_institutionId);
    if (mounted) {
      setState(() {
        _departments = depts;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddDeptDialog() async {
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Department', style: AppTextStyles.h3),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              hintText: 'e.g. Faculty of Computer Science',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
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
              await db.createDepartment(_institutionId, nameCtrl.text.trim());
              _loadData();
            },
            child: const Text('Add Department'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Departments'),
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
          : _departments.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.apartment_outlined,
                  title: 'No Departments',
                  description: 'Create faculty departments for your institution.',
                  actionLabel: 'Add Department',
                  onAction: _showAddDeptDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _departments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _departments[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.business_rounded, color: AppColors.navy),
                        ),
                        title: Text(item.name, style: AppTextStyles.h3),
                        trailing: StatusBadge.fromString(item.status),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeptDialog,
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Department'),
      ),
    );
  }
}
