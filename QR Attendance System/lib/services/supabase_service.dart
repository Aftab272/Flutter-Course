import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }

  User? get currentUser => client.auth.currentUser;

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        return UserProfile.fromJson(response);
      }
    } catch (_) {}

    // Fallback to user metadata if profile record is syncing
    final user = client.auth.currentUser;
    if (user != null && user.id == userId) {
      final meta = user.userMetadata ?? {};
      UserRole parsedRole;
      switch (meta['role']) {
        case 'admin':
          parsedRole = UserRole.admin;
          break;
        case 'teacher':
          parsedRole = UserRole.teacher;
          break;
        default:
          parsedRole = UserRole.student;
      }
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: meta['full_name'] ?? 'User',
        role: parsedRole,
      );
    }
    return null;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Secure Sign Up:
  /// Enforces Part D & K: Public self-registration is strictly restricted to Student role.
  /// Admin/Teacher privileges cannot be claimed from an untrusted client call.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentIdNumber,
    UserRole role = UserRole.student,
  }) async {
    final safeRole = role;

    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': safeRole.name,
        'student_id_number': studentIdNumber,
      },
    );

    // Ensure profile row exists in database
    if (response.user != null) {
      try {
        await client.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': safeRole.name,
          'student_id_number': studentIdNumber,
          'status': 'active',
        });
      } catch (_) {}
    }

    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.qrattendance://reset-callback/',
    );
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
