import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF005CAD);
  static const Color secondary = Color(0xFF1769E0);
  static const Color tertiary = Color(0xFF87CEEB);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF3FF);
  static const Color surfaceContainerHigh = Color(0xFFDDE9FF);
  static const Color onSurface = Color(0xFF001C39);
  static const Color onSurfaceVariant = Color(0xFF414753);
  static const Color outline = Color(0xFF717784);
  static const Color outlineVariant = Color(0xFFC0C6D5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        onSurface: onSurface,
      ),
      fontFamily: 'Manrope',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xDCF8F9FF),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Manrope',
        ),
      ),
    );
  }
}
