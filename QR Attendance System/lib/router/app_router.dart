import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/admin/admin_dashboard_screen.dart';
import '../ui/screens/admin/manage_classes_screen.dart';
import '../ui/screens/admin/manage_subjects_screen.dart';
import '../ui/screens/admin/manage_departments_screen.dart';
import '../ui/screens/admin/manage_academic_terms_screen.dart';
import '../ui/screens/admin/manage_users_screen.dart';
import '../ui/screens/teacher/teacher_dashboard_screen.dart';
import '../ui/screens/student/student_dashboard_screen.dart';
import '../ui/screens/shared/profile_screen.dart';
import '../ui/screens/shared/offline_queue_screen.dart';
import '../ui/screens/shared/drive_backup_screen.dart';
import '../ui/screens/admin/reports_screen.dart';
import '../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/classes',
        builder: (context, state) => const ManageClassesScreen(),
      ),
      GoRoute(
        path: '/admin/subjects',
        builder: (context, state) => const ManageSubjectsScreen(),
      ),
      GoRoute(
        path: '/admin/departments',
        builder: (context, state) => const ManageDepartmentsScreen(),
      ),
      GoRoute(
        path: '/admin/terms',
        builder: (context, state) => const ManageAcademicTermsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const ManageUsersScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/offline-queue',
        builder: (context, state) => const OfflineQueueScreen(),
      ),
      GoRoute(
        path: '/drive-backup',
        builder: (context, state) => const DriveBackupScreen(),
      ),
    ],
  );
});
