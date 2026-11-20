import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../services/supabase_service.dart';
import '../../services/research_service.dart';
import '../../shared/widgets/lootify_logo.dart';

/// Clean Create Account Screen (Section 16 & 17)
/// Features only the primary registration form and a Sign In navigation link below.
/// All unnecessary third-party buttons and quick demo sections have been removed.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatNameFromEmail(String email) {
    try {
      final handle = email.split('@').first.replaceAll(RegExp(r'[\._\-]'), ' ');
      final words = handle.split(' ').where((w) => w.isNotEmpty);
      if (words.isEmpty) return 'Lootify User';
      return words.map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    } catch (_) {
      return 'Lootify User';
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      name = _formatNameFromEmail(email);
    }

    try {
      final supabase = SupabaseService();
      if (supabase.client != null) {
        await supabase.signUp(
          email: email,
          password: password,
          fullName: name,
        );
      }
    } catch (_) {
      // Continue gracefully
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    final avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=9333EA&color=fff&size=200&bold=true';
    final existingUser = ResearchService().user;
    ResearchService().updateUser(existingUser.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workspace created successfully for $name!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CustomCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: LootifyLogo(
                        iconSize: 44,
                        fontSize: 26,
                        showText: true,
                        text: 'Lootify Scrap',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Your Lootify Scrap Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start researching multi-marketplace e-commerce trends',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Full Name
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'e.g. Rana Aftab Akram',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Work Email
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Original Email Address',
                      hintText: 'e.g. name@company.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: '••••••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: '••••••••••••',
                      prefixIcon: Icons.lock_clock_outlined,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Terms Checkbox
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            activeColor: theme.colorScheme.primary,
                            checkColor: Colors.white,
                            side: BorderSide(color: theme.dividerColor),
                            onChanged: (v) => setState(() => _acceptTerms = v ?? true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Primary Create Account Button
                    CustomButton(
                      text: 'Create Account',
                      type: ButtonType.primary,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20),

                    // Clean Sign In link below
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.65), fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
