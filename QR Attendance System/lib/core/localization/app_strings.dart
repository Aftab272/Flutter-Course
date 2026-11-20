import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, urdu }

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'user_app_locale';

  @override
  Locale build() {
    _loadLocale();
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code == 'ur') {
        state = const Locale('ur');
      } else {
        state = const Locale('en');
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    final newLocale = language == AppLanguage.urdu ? const Locale('ur') : const Locale('en');
    state = newLocale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newLocale.languageCode);
    } catch (_) {}
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      setLanguage(AppLanguage.urdu);
    } else {
      setLanguage(AppLanguage.english);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Simple type-safe AppStrings helper for English & Urdu
class AppStrings {
  final String languageCode;

  AppStrings(this.languageCode);

  bool get isUrdu => languageCode == 'ur';

  // App Identity
  String get appName => isUrdu ? 'کیو آر حاضری نظام' : 'QR Attendance System';
  String get tagline => isUrdu ? 'سمارٹ حاضری، سادہ اور محفوظ' : 'Smart Attendance. Simple & Secure.';
  String get publisher => 'Creative Stack Agency';

  // Common Actions
  String get login => isUrdu ? 'لاگ اِن' : 'Login';
  String get register => isUrdu ? 'رجسٹر کریں' : 'Register';
  String get logout => isUrdu ? 'لاگ آؤٹ' : 'Logout';
  String get save => isUrdu ? 'محفوظ کریں' : 'Save';
  String get cancel => isUrdu ? 'منسوخ' : 'Cancel';
  String get close => isUrdu ? 'بند کریں' : 'Close';
  String get retry => isUrdu ? 'دوبارہ کوشش کریں' : 'Retry';
  String get search => isUrdu ? 'تلاش کریں...' : 'Search...';
  String get filter => isUrdu ? 'فلٹر' : 'Filter';
  String get export => isUrdu ? 'ایکسپورٹ' : 'Export';
  String get refresh => isUrdu ? 'ریفریش' : 'Refresh';

  // Statuses
  String get present => isUrdu ? 'حاضر (Present)' : 'Present';
  String get late => isUrdu ? 'تاخیر (Late)' : 'Late';
  String get absent => isUrdu ? 'غیر حاضر (Absent)' : 'Absent';
  String get pendingSync => isUrdu ? 'آف لائن کیو (Pending Sync)' : 'Pending Sync';
  String get confirmed => isUrdu ? 'تصدیق شدہ (Confirmed)' : 'Server Confirmed';

  // Roles & Dashboards
  String get adminPortal => isUrdu ? 'ایڈمن پورٹل' : 'Administrator Portal';
  String get teacherPortal => isUrdu ? 'اساتذہ پورٹل' : 'Teacher Portal';
  String get studentPortal => isUrdu ? 'طالب علم پورٹل' : 'Student Portal';

  // QR & Attendance
  String get startSession => isUrdu ? 'حاضری سیشن شروع کریں' : 'Start Attendance Session';
  String get closeSession => isUrdu ? 'سیشن بند کریں' : 'Close Session';
  String get scanQr => isUrdu ? 'کیو آر کوڈ اسکین کریں' : 'Scan Attendance QR';
  String get qrExpiresIn => isUrdu ? 'کیو آر ختم ہونے کا وقت:' : 'QR Expires in:';
  String get duplicateError => isUrdu ? 'آپ کی حاضری پہلے ہی درج ہو چکی ہے' : 'Attendance already recorded for this session.';
  String get sessionClosed => isUrdu ? 'یہ سیشن بند ہو چکا ہے' : 'This attendance session has ended.';
  String get qrExpired => isUrdu ? 'کیو آر کوڈ ایکسپائر ہو چکا ہے' : 'QR code has expired.';

  // Backups & Sync
  String get backupAndRestore => isUrdu ? 'بیک اپ اور ری اسٹور' : 'Backup & Restore';
  String get offlineQueue => isUrdu ? 'آف لائن کیو' : 'Offline Attendance Queue';
  String get syncNow => isUrdu ? 'ابھی سنک کریں' : 'Sync Now';
}

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale.languageCode);
});
