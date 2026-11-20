import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/app_providers.dart';
import '../../../models/app_models.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final supabase = ref.read(supabaseServiceProvider);
      AuthResponse? res;

      // 1. Try standard sign-in first
      try {
        res = await supabase.signIn(
          email: email,
          password: password,
        );
      } catch (signInErr) {
        final errStr = signInErr.toString();
        // If account does not exist, automatically register this new user on the fly!
        if (errStr.contains('Invalid login credentials') ||
            errStr.contains('invalid_credentials')) {
          final namePart = email.split('@').first;
          final defaultName = namePart.isNotEmpty
              ? namePart[0].toUpperCase() + namePart.substring(1)
              : 'User';

          final signUpRes = await supabase.signUp(
            email: email,
            password: password,
            fullName: defaultName,
            role: _selectedRole,
          );

          // If identities is empty, the user already existed with a different password
          if (signUpRes.user != null &&
              signUpRes.user!.identities != null &&
              signUpRes.user!.identities!.isEmpty) {
            setState(() {
              _errorMessage =
                  'An account with this email already exists, but the password entered was incorrect. Please check your password.';
            });
            return;
          }

          // If sign up succeeded, check session or log in
          if (signUpRes.session != null) {
            res = signUpRes;
          } else {
            try {
              res = await supabase.signIn(email: email, password: password);
            } catch (_) {
              if (signUpRes.user != null) {
                setState(() {
                  _errorMessage =
                      'Account created! If login does not proceed, please verify email in your inbox or disable "Confirm email" in Supabase.';
                });
                return;
              }
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      if (res.user != null) {
        final profile = await supabase.fetchUserProfile(res.user!.id);
        if (profile != null) {
          ref.read(authUserProvider.notifier).setUser(profile);
          if (!mounted) return;
          if (profile.role == UserRole.admin) {
            context.go('/admin');
          } else if (profile.role == UserRole.teacher) {
            context.go('/teacher');
          } else {
            context.go('/student');
          }
          return;
        }
      }
      setState(() {
        _errorMessage = 'User profile could not be retrieved.';
      });
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('Email not confirmed')) {
          _errorMessage =
              'Email address has not been confirmed yet. Please check your inbox or disable "Confirm email" in Supabase dashboard.';
        } else {
          _errorMessage = e.message;
        }
      });
    } catch (e) {
      final msg = e.toString();
      setState(() {
        _errorMessage = msg.replaceFirst('Exception: ', '').replaceFirst('AuthApiException: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.royalBlue, AppColors.skyBlue],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QR Attendance System',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to your account',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 24),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.errorDark, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.errorDark, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'user@institution.edu',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter your password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Role Selection (Auto-assigned for new accounts)
                      DropdownButtonFormField<UserRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role / Portal',
                          prefixIcon: Icon(Icons.badge_outlined),
                          helperText: 'New accounts will be created with this role',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.student,
                            child: Row(
                              children: [
                                Icon(Icons.school_outlined, size: 20, color: AppColors.royalBlue),
                                SizedBox(width: 8),
                                Text('Student'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: UserRole.teacher,
                            child: Row(
                              children: [
                                Icon(Icons.menu_book_outlined, size: 20, color: AppColors.success),
                                SizedBox(width: 8),
                                Text('Teacher'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: UserRole.admin,
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings_outlined, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Admin'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (role) {
                          if (role != null) {
                            setState(() => _selectedRole = role);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      AppButton(
                        text: 'Sign In / Instant Access',
                        onPressed: _login,
                        isLoading: _isLoading,
                        variant: AppButtonVariant.primary,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Register Link
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text("Or open detailed Registration Form"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
