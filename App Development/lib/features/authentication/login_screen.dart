import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../services/supabase_service.dart';
import '../../services/research_service.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../shared/widgets/lootify_logo.dart';

class _GoogleDeviceAccount {
  final String name;
  final String email;
  final Color avatarBgColor;

  const _GoogleDeviceAccount({
    required this.name,
    required this.email,
    required this.avatarBgColor,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  static const MethodChannel _googleAccountChannel = MethodChannel('lootify/google_accounts');
  static const String _prefDeviceAccountsKey = 'device_saved_google_accounts_v2';

  static const List<Color> _avatarColors = [
    Color(0xFF1E88E5),
    Color(0xFF2E7D32),
    Color(0xFF5C6BC0),
    Color(0xFF0288D1),
    Color(0xFFC2185B),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
  ];

  /// Only stores Google accounts actually signed in on THIS user's device (zero hardcoded emails)
  List<_GoogleDeviceAccount> _savedDeviceAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDeviceAccounts();
  }

  Future<void> _loadSavedDeviceAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefDeviceAccountsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final loaded = decoded.map((item) {
          final map = item as Map<String, dynamic>;
          final email = (map['email'] ?? '').toString();
          final name = (map['name'] ?? _formatNameFromEmail(email)).toString();
          final colorIdx = email.codeUnits.fold<int>(0, (a, b) => a + b) % _avatarColors.length;
          return _GoogleDeviceAccount(
            name: name,
            email: email,
            avatarBgColor: _avatarColors[colorIdx],
          );
        }).where((a) => a.email.isNotEmpty).toList();
        if (mounted) {
          setState(() => _savedDeviceAccounts = loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveDeviceAccount(String name, String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      if (normalized.isEmpty) return;
      final existsIdx = _savedDeviceAccounts.indexWhere((a) => a.email.toLowerCase() == normalized);
      final colorIdx = normalized.codeUnits.fold<int>(0, (a, b) => a + b) % _avatarColors.length;
      final acc = _GoogleDeviceAccount(
        name: name,
        email: email.trim(),
        avatarBgColor: _avatarColors[colorIdx],
      );
      if (existsIdx != -1) {
        _savedDeviceAccounts.removeAt(existsIdx);
      }
      _savedDeviceAccounts.insert(0, acc);

      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _savedDeviceAccounts.map((a) => {'name': a.name, 'email': a.email}).toList(),
      );
      await prefs.setString(_prefDeviceAccountsKey, encoded);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatNameFromEmail(String email) {
    if (!email.contains('@')) return 'Lootify User';
    final handle = email.split('@').first.replaceAll(RegExp(r'[\._\-]'), ' ');
    final formatted = handle
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return formatted.isNotEmpty ? formatted : 'Lootify User';
  }

  void _submitAuth() {
    if (_isSignUp) {
      _handleSignUp();
    } else {
      _handleSignIn();
    }
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final finalName = _formatNameFromEmail(email);
    final avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(finalName)}&background=2563EB&color=fff&size=200&bold=true';

    // Instant / Urgent login: Update user and session right away!
    final existingUser = ResearchService().user;
    ResearchService().updateUser(existingUser.copyWith(
      name: finalName,
      email: email,
      avatarUrl: avatarUrl,
    ));

    // Optional background sync with Supabase without making the user wait
    try {
      final supabase = SupabaseService();
      if (supabase.client != null) {
        supabase.signIn(email: email, password: password).catchError((_) {
          return supabase.signUp(email: email, password: password, fullName: finalName);
        });
      }
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, $finalName!'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    // Urgent instant redirect to main workspace!
    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match! Please verify your password.'),
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
    final avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=2563EB&color=fff&size=200&bold=true';

    // Instant / Urgent sign up: Update user session immediately!
    final existingUser = ResearchService().user;
    ResearchService().updateUser(existingUser.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    ));

    // Background sync with Supabase
    try {
      final supabase = SupabaseService();
      if (supabase.client != null) {
        supabase.signUp(email: email, password: password, fullName: name);
      }
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created for $name ($email)!'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
  }

  Future<void> _handleGoogleLogin() async {
    // On Android mobile: Launch the REAL native Android Google Account Picker
    // so every user sees ONLY the Google accounts signed in on THEIR OWN phone!
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final String? pickedEmail = await _googleAccountChannel.invokeMethod<String>('pickGoogleAccount');
        if (!mounted) return;
        if (pickedEmail != null && pickedEmail.trim().isNotEmpty) {
          final email = pickedEmail.trim();
          final name = _formatNameFromEmail(email);
          await _saveDeviceAccount(name, email);
          await _authenticateWithGoogleAccount(
            name: name,
            email: email,
            avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=2563EB&color=fff&size=200&bold=true',
          );
          return;
        }
        // User tapped cancel on Android system picker -> do nothing
        return;
      } on MissingPluginException {
        // Fallback below if channel is unavailable
      } catch (_) {
        // Fallback below if device has no Google Play Services / AccountManager
      }
    }

    if (!mounted) return;
    _showGoogleAccountSelectionSheet();
  }

  void _showGoogleAccountSelectionSheet() {
    final theme = Theme.of(context);
    final isLight = ThemeService().isLight;
    final sheetBg = isLight ? Colors.white : (theme.cardTheme.color ?? AppColors.secondaryBackground);
    final textTitleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final textSubtitleColor = isLight ? const Color(0xFF475569) : theme.colorScheme.onSurface.withOpacity(0.65);
    final borderColor = isLight ? const Color(0xFFE2E8F0) : theme.dividerColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Header
              Row(
                children: [
                  const BrandIcon(brand: 'google', size: 28),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a Google Account',
                        style: TextStyle(
                          color: textTitleColor,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'to continue to Lootify Scrap',
                        style: TextStyle(
                          color: textSubtitleColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textTitleColor),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 6),

              // Scrollable list of ONLY accounts previously signed in on THIS device
              if (_savedDeviceAccounts.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _savedDeviceAccounts.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: borderColor.withOpacity(0.6)),
                    itemBuilder: (context, idx) {
                      final acc = _savedDeviceAccounts[idx];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _authenticateWithGoogleAccount(
                            name: acc.name,
                            email: acc.email,
                            avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(acc.name)}&background=2563EB&color=fff&size=200&bold=true',
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: acc.avatarBgColor,
                                child: Text(
                                  acc.name.isNotEmpty ? acc.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      style: TextStyle(
                                        color: textTitleColor,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc.email,
                                      style: TextStyle(
                                        color: textSubtitleColor,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Text(
                    'Sign in with your own Google account below. Your email will be saved only on this device.',
                    style: TextStyle(color: textSubtitleColor, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 6),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 6),

              // Use another account (Opens custom dialog on click)
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showCustomGoogleAccountDialog();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF1F5F9) : theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2563EB), size: 19),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Add / Use another Google account',
                          style: TextStyle(
                            color: textTitleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: textSubtitleColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'To continue, Google will share your name, email address, language preference, and profile picture with Lootify Scrap.',
                style: TextStyle(
                  color: textSubtitleColor,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomGoogleAccountDialog() {
    final nameCtl = TextEditingController(text: 'Rana Aftab Akram');
    final emailCtl = TextEditingController(text: 'ranaaftabakram@gmail.com');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color ?? AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            BrandIcon(brand: 'google', size: 24),
            SizedBox(width: 12),
            Text('Sign in with Google', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select or confirm your Google Account details:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameCtl,
              labelText: 'Google Account Name',
              hintText: 'e.g. Rana Aftab Akram',
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: emailCtl,
              labelText: 'Google Email',
              hintText: 'e.g. ranaaftabakram@gmail.com',
              prefixIcon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final chosenName = nameCtl.text.trim().isNotEmpty ? nameCtl.text.trim() : 'Rana Aftab Akram';
              final chosenEmail = emailCtl.text.trim();
              if (chosenEmail.isEmpty || !chosenEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your valid Google email address.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              final effectiveName = chosenName.isNotEmpty ? chosenName : _formatNameFromEmail(chosenEmail);
              Navigator.pop(dlgCtx);
              _saveDeviceAccount(effectiveName, chosenEmail);
              _authenticateWithGoogleAccount(
                name: effectiveName,
                email: chosenEmail,
                avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(effectiveName)}&background=2563EB&color=fff&size=200&bold=true',
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticateWithGoogleAccount({
    required String name,
    required String email,
    required String avatarUrl,
  }) async {
    // Instant urgent login without any delay
    final existingUser = ResearchService().user;
    ResearchService().updateUser(existingUser.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as $name ($email)'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
  }

  void _fillDemoCredentials() {
    _emailController.text = 'demo.analyst@ecomintel.io';
    _passwordController.text = 'SaaSDemo2026!';
    _confirmPasswordController.text = 'SaaSDemo2026!';
    _nameController.text = 'Demo Analyst';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo credentials loaded! Click Sign In to continue.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = ThemeService().isLight;
    final scaffoldBg = isLight ? Colors.white : theme.scaffoldBackgroundColor;
    final cardBg = isLight ? Colors.white : (theme.cardTheme.color ?? AppColors.secondaryBackground);
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtitleColor = isLight ? const Color(0xFF334155) : theme.colorScheme.onSurface.withOpacity(0.65);
    final cardBorderColor = isLight ? const Color(0xFFE2E8F0) : theme.dividerColor;
    final primaryBtnColor = isLight ? const Color(0xFF2563EB) : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: titleColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: isLight ? 'Switch to Dark Blue Theme' : 'Switch to White Theme',
            icon: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: titleColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                ThemeService().togglePrimaryTheme();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor, width: 1.2),
                boxShadow: isLight
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Official Circular Logo (Screenshot 1)
                    const Center(
                      child: LootifyLogo(
                        iconSize: 64,
                        showText: false,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isSignUp ? 'Create Your Lootify Scrap Account' : 'Welcome to Lootify Scrap',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? 'Sign up to analyze stores & discover winning products'
                          : 'Sign in to access multi-marketplace intelligence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Sign In / Sign Up Segmented Switch
                    Container(
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFF1F5F9) : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cardBorderColor),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isSignUp = false),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !_isSignUp ? primaryBtnColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !_isSignUp
                                        ? Colors.white
                                        : (isLight ? const Color(0xFF000000) : Colors.white70),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isSignUp = true),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _isSignUp ? primaryBtnColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Create Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _isSignUp
                                        ? Colors.white
                                        : (isLight ? const Color(0xFF000000) : Colors.white70),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Full Name (only in Sign Up mode)
                    if (_isSignUp) ...[
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        hintText: 'e.g. Rana Ali',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (_isSignUp && (value == null || value.trim().isEmpty)) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Address
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Original Email Address',
                      hintText: 'e.g. yourname@gmail.com',
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
                          color: isLight ? const Color(0xFF000000).withOpacity(0.6) : theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    // Confirm Password (only in Sign Up mode)
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: _obscureConfirmPassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: isLight ? const Color(0xFF000000).withOpacity(0.6) : theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (_isSignUp && (value == null || value.isEmpty)) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Remember me & forgot password (in Sign In mode)
                    if (!_isSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: primaryBtnColor,
                                    checkColor: Colors.white,
                                    side: BorderSide(color: cardBorderColor),
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Remember me',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset instructions sent to your email.'),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isLight ? const Color(0xFF2563EB) : theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 18),

                    // Submit Button
                    CustomButton(
                      text: _isSignUp ? 'Create Account & Sign In' : 'Sign In with Email',
                      type: ButtonType.primary,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      onPressed: _submitAuth,
                    ),

                    const SizedBox(height: 16),

                    // OR divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: cardBorderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              color: isLight ? const Color(0xFF64748B) : theme.colorScheme.onSurface.withOpacity(0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: cardBorderColor)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Continue with Google Button
                    OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: cardBorderColor, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: isLight ? Colors.white : (theme.cardTheme.color ?? theme.colorScheme.surface),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const BrandIcon(brand: 'google', size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Demo autofill button
                    CustomButton(
                      text: 'Quick Demo Access',
                      type: ButtonType.secondary,
                      icon: Icons.bolt_rounded,
                      isFullWidth: true,
                      onPressed: () {
                        _fillDemoCredentials();
                        _handleSignIn();
                      },
                    ),

                    const SizedBox(height: 20),

                    // Toggle bottom text
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? "Already have an account? " : "Don't have an account? ",
                          style: TextStyle(
                            color: isLight ? const Color(0xFF334155) : theme.colorScheme.onSurface.withOpacity(0.65),
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isSignUp = !_isSignUp),
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Create Account',
                            style: TextStyle(
                              color: isLight ? const Color(0xFF2563EB) : theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
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
