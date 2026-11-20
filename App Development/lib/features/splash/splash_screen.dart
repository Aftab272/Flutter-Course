import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../services/supabase_service.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/lootify_logo.dart';

/// App Launch Splash Screen (PART 7)
/// - Displays the original LootifyScrap logo centered on the existing theme background.
/// - Smoothly animates from zoomed-in (1.32x) to normal size (1.0x) — zoom-out effect.
/// - Total duration: exactly 3 seconds.
/// - Navigates automatically to MainShell (if signed in) or LoginScreen on completion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _zoomOutAnimation;
  late final Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Smooth zoom-out animation: starts slightly zoomed-in (1.32x) and settles to normal (1.0x)
    _zoomOutAnimation = Tween<double>(begin: 1.32, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Subtle smooth fade-in during the first 25% of the 3-second launch
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });

    _controller.forward();
  }

  void _navigateNext() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final isSignedIn = SupabaseService().currentUser != null;
    Navigator.pushReplacementNamed(
      context,
      isSignedIn ? AppRoutes.mainShell : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeService().isLight;
    final bgColor = isLight ? Colors.white : const Color(0xFF0A1128);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _zoomOutAnimation,
              child: const LootifyLogo(
                iconSize: 140,
                showText: false,
                preferOfficialArtwork: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
