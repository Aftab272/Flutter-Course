import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../services/theme_service.dart';

class AppTheme {
  static ThemeData get darkTheme => getTheme(ThemeService().currentPreset);

  static ThemeData getTheme(ThemePreset preset) {
    final palette = ThemeService.presets[preset]!;
    final isLight = palette.isLight;

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: palette.primary,
              secondary: palette.accent,
              surface: palette.surface,
              error: AppColors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: palette.primaryText,
              onError: Colors.white,
              outline: palette.border,
            )
          : ColorScheme.dark(
              primary: palette.primary,
              secondary: palette.accent,
              surface: palette.surface,
              error: AppColors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: palette.primaryText,
              onError: Colors.white,
              outline: palette.border,
            ),
      dividerColor: palette.border,
      fontFamily: ThemeService().fontFamily,
      textTheme: isLight
          ? const TextTheme(
              displayLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w800),
              displayMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w800),
              displaySmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              headlineLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w800),
              headlineMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              headlineSmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              titleLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              titleMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              titleSmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w500),
              bodySmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w500),
              labelLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w700),
              labelMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600),
              labelSmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w600),
            )
          : null,
      iconTheme: IconThemeData(color: isLight ? const Color(0xFF000000) : palette.primaryText),
      listTileTheme: ListTileThemeData(
        textColor: isLight ? const Color(0xFF000000) : palette.primaryText,
        iconColor: isLight ? const Color(0xFF000000) : palette.primaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: palette.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: palette.primaryText),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : palette.surface,
        hintStyle: TextStyle(
          color: isLight ? const Color(0xFF64748B) : palette.secondaryText,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isLight ? const Color(0xFFE2E8F0) : palette.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isLight ? const Color(0xFFCBD5E1) : palette.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primaryText,
          side: BorderSide(color: palette.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        contentTextStyle: TextStyle(color: palette.primaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
