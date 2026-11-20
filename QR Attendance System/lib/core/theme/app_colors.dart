import 'package:flutter/material.dart';

/// Central Design System Color Tokens for QR Attendance System
/// Matches the Part C UX specifications:
/// - Deep navy blue for headings & navigation
/// - Royal blue for primary actions
/// - Sky blue for secondary accents
/// - Neutral soft gray for backgrounds & dividers
/// - Semantic Green, Amber, and Red for statuses
class AppColors {
  AppColors._();

  // Primary & Secondary Brand Colors
  static const Color navyDark = Color(0xFF0F172A); // Slate 900
  static const Color navy = Color(0xFF1E293B);     // Slate 800
  static const Color navyLight = Color(0xFF334155);

  static const Color royalBlue = Color(0xFF1D4ED8); // Blue 700 - Primary actions
  static const Color royalBlueLight = Color(0xFF2563EB); // Blue 600 - Hover / Highlight
  static const Color royalBlueDark = Color(0xFF1E40AF);  // Blue 800

  static const Color skyBlue = Color(0xFF0EA5E9);      // Sky 500 - Secondary accents
  static const Color skyBlueLight = Color(0xFFE0F2FE); // Sky 100
  static const Color skyBlueAccent = Color(0xFF38BDF8);

  // Neutral Backgrounds & Surfaces (Light Mode)
  static const Color bgLight = Color(0xFFF8FAFC);      // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);   // Slate 200
  static const Color dividerLight = Color(0xFFF1F5F9);  // Slate 100

  // Neutral Backgrounds & Surfaces (Dark Mode)
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF1E293B);   // Slate 800
  static const Color surfaceDarkElevated = Color(0xFF273549);
  static const Color borderDark = Color(0xFF334155);    // Slate 700

  // Typography Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textSecondary = textSecondaryLight;
  static const Color neutralSlate = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);       // Emerald 500 - Present
  static const Color successLight = Color(0xFFD1FAE5);  // Emerald 100
  static const Color successDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B);       // Amber 500 - Late
  static const Color warningLight = Color(0xFFFEF3C7);  // Amber 100
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFEF4444);         // Red 500 - Absent / Error
  static const Color errorLight = Color(0xFFFEE2E2);    // Red 100
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
}
