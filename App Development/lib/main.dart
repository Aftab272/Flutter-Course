import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/supabase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system overlay immediately
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF171717),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Launch UI immediately (0ms startup block) and initialize cloud backend in background
  runApp(const ShopScraperApp());
  SupabaseService().init();
}
