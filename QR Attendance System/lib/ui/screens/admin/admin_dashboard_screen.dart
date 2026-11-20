import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../providers/app_providers.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _classesCount = 0;
  int _subjectsCount = 0;
  int _studentsCount = 0;
  int _teachersCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = ref.read(databaseServiceProvider);
    final user = ref.read(authUserProvider);
    final instId = user?.institutionId ?? await db.getOrCreateDefaultInstitution();

    final classes = await db.getClasses(instId);
    final subjects = await db.getAllSubjects(instId);
    final students = await db.getUsersByRole('student', institutionId: instId);
    final teachers = await db.getUsersByRole('teacher', institutionId: instId);

    if (mounted) {
      setState(() {
        _classesCount = classes.length;
        _subjectsCount = subjects.length;
        _studentsCount = students.length;
        _teachersCount = teachers.length;
        _isLoadingStats = false;
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => Consumer(
        builder: (context, ref, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final currentLocale = ref.watch(localeProvider);

          return AlertDialog(
            title: const Text('System Settings', style: AppTextStyles.h3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                  value: isDark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Language (زبان)'),
                  subtitle: Text(currentLocale.languageCode == 'ur' ? 'اردو (Urdu)' : 'English'),
                  trailing: const Icon(Icons.language),
                  onTap: () {
                    ref.read(localeProvider.notifier).toggleLanguage();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    final db = ref.watch(databaseServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Backup & Restore',
            onPressed: () => context.go('/drive-backup'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Card(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.navyDark, AppColors.royalBlue],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, size: 36, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Institution Administrator',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.fullName ?? 'Administrator',
                              style: AppTextStyles.h2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Metrics Section (Part E)
              const Text('Institutional Overview', style: AppTextStyles.h3),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 550;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: isWide ? 1.4 : 1.3,
                    children: [
                      _StatCard(
                        title: 'Total Classes',
                        value: _isLoadingStats ? '...' : '$_classesCount',
                        icon: Icons.class_outlined,
                        color: AppColors.royalBlue,
                      ),
                      _StatCard(
                        title: 'Total Subjects',
                        value: _isLoadingStats ? '...' : '$_subjectsCount',
                        icon: Icons.menu_book_outlined,
                        color: AppColors.skyBlue,
                      ),
                      _StatCard(
                        title: 'Active Students',
                        value: _isLoadingStats ? '...' : '$_studentsCount',
                        icon: Icons.school_outlined,
                        color: AppColors.success,
                      ),
                      _StatCard(
                        title: 'Faculty Members',
                        value: _isLoadingStats ? '...' : '$_teachersCount',
                        icon: Icons.badge_outlined,
                        color: AppColors.navy,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Management Modules Grid (Part E & H)
              const Text('Administrative Modules', style: AppTextStyles.h3),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  _ModuleCard(
                    title: 'Manage Classes',
                    subtitle: 'Classes & sections',
                    icon: Icons.school_rounded,
                    color: AppColors.royalBlue,
                    onTap: () => context.go('/admin/classes'),
                  ),
                  _ModuleCard(
                    title: 'Manage Subjects',
                    subtitle: 'Courses & codes',
                    icon: Icons.book_rounded,
                    color: AppColors.skyBlue,
                    onTap: () => context.go('/admin/subjects'),
                  ),
                  _ModuleCard(
                    title: 'User Management',
                    subtitle: 'Enrollment & teachers',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.success,
                    onTap: () => context.go('/admin/users'),
                  ),
                  _ModuleCard(
                    title: 'Departments',
                    subtitle: 'Academic faculties',
                    icon: Icons.apartment_rounded,
                    color: AppColors.navyLight,
                    onTap: () => context.go('/admin/departments'),
                  ),
                  _ModuleCard(
                    title: 'Academic Terms',
                    subtitle: 'Semesters & dates',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.warning,
                    onTap: () => context.go('/admin/terms'),
                  ),
                  _ModuleCard(
                    title: 'Audit Logs',
                    subtitle: 'Security history',
                    icon: Icons.security_rounded,
                    color: AppColors.royalBlueDark,
                    onTap: () async {
                      final logs = await db.getAuditLogs();
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('System Audit Logs', style: AppTextStyles.h3),
                          content: SizedBox(
                            width: 500,
                            height: 400,
                            child: logs.isEmpty
                                ? const Center(child: Text('No audit logs recorded.'))
                                : ListView.builder(
                                    itemCount: logs.length,
                                    itemBuilder: (context, index) {
                                      final log = logs[index];
                                      return ListTile(
                                        title: Text(log.action, style: AppTextStyles.bodyMedium),
                                        subtitle: Text(log.details ?? 'No details provided'),
                                        trailing: Text(
                                          log.createdAt.toString().substring(0, 16),
                                          style: AppTextStyles.caption,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: 'Reports & Exports',
                    subtitle: 'CSV, PDF & analytics',
                    icon: Icons.analytics_rounded,
                    color: AppColors.success,
                    onTap: () => context.go('/admin/reports'),
                  ),
                  _ModuleCard(
                    title: 'Cloud Backup',
                    subtitle: 'Google Drive backup',
                    icon: Icons.cloud_sync_rounded,
                    color: AppColors.skyBlue,
                    onTap: () => context.go('/drive-backup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
