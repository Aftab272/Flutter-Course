import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';

class ManageAcademicTermsScreen extends ConsumerStatefulWidget {
  const ManageAcademicTermsScreen({super.key});

  @override
  ConsumerState<ManageAcademicTermsScreen> createState() => _ManageAcademicTermsScreenState();
}

class _ManageAcademicTermsScreenState extends ConsumerState<ManageAcademicTermsScreen> {
  bool _isLoading = true;
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

    final terms = await db.getAcademicTerms(_institutionId);
    if (mounted) {
      setState(() {
        _terms = terms;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddTermDialog() async {
    final nameCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 120));
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Academic Term', style: AppTextStyles.h3),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Term Name',
                      hintText: 'e.g. Fall 2026 / Spring 2027',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter term name' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date', style: AppTextStyles.bodyMedium),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(startDate)),
                    trailing: const Icon(Icons.calendar_today, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDialogState(() => startDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date', style: AppTextStyles.bodyMedium),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                    trailing: const Icon(Icons.calendar_today, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDialogState(() => endDate = picked);
                      }
                    },
                  ),
                ],
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
                await db.createAcademicTerm(
                  institutionId: _institutionId,
                  name: nameCtrl.text.trim(),
                  startDate: startDate,
                  endDate: endDate,
                );
                _loadData();
              },
              child: const Text('Save Term'),
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
        title: const Text('Academic Terms & Semesters'),
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
          : _terms.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.date_range_outlined,
                  title: 'No Terms Created',
                  description: 'Add academic semesters or sessions to manage class schedules.',
                  actionLabel: 'Add Term',
                  onAction: _showAddTermDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _terms.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _terms[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: AppColors.royalBlue),
                        ),
                        title: Text(item.name, style: AppTextStyles.h3),
                        subtitle: Text(
                          '${DateFormat('MMM d, yyyy').format(item.startDate)} - ${DateFormat('MMM d, yyyy').format(item.endDate)}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: StatusBadge.fromString(item.status),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTermDialog,
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Term'),
      ),
    );
  }
}
