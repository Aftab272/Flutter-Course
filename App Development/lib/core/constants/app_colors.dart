import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class AppColors {
  // Default SaaS Theme Constants (Always available as compile-time constants)
  static const Color primaryBackground = Color(0xFF000000);
  static const Color secondaryBackground = Color(0xFF171717);
  static const Color cardBackground = Color(0xFF171717);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA7A7A7);
  static const Color primaryGreen = Color(0xFF00A878);
  static const Color accentLime = Color(0xFFB7F34A);
  static const Color borderColor = Color(0xFF303030);

  // Dynamic Theme-Adaptive Getters (100% Full Black #000000 in Light Mode)
  static Color get adaptiveText => ThemeService().textColor;
  static Color get adaptiveSubtext => ThemeService().subtextColor;
  static Color get adaptiveSurface => ThemeService().isLight ? const Color(0xFFFFFFFF) : secondaryBackground;
  static Color get adaptiveBackground => ThemeService().isLight ? const Color(0xFFFFFFFF) : primaryBackground;
  static Color get adaptiveCard => ThemeService().isLight ? const Color(0xFFFFFFFF) : cardBackground;

  // Functional & Semantic Colors
  static const Color cardHover = Color(0xFF222222);
  static const Color surfaceLight = Color(0xFF1F1F1F);
  static const Color divider = Color(0xFF262626);
  static const Color error = Color(0xFFFF5C5C);
  static const Color warning = Color(0xFFFFB800);
  static const Color success = Color(0xFF00A878);
  static const Color info = Color(0xFF38BDF8);

 
  // Marketplace Brand Accents
  static const Color etsyColor = Color(0xFFF1641E);
  static const Color amazonColor = Color(0xFFFF9900);
  static const Color ebayColor = Color(0xFF0064D2);
  static const Color shopifyColor = Color(0xFF96BF48);
}
