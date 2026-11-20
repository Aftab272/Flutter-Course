import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_scraper_app/core/theme/app_theme.dart';
import 'package:shop_scraper_app/services/theme_service.dart';
import 'package:shop_scraper_app/shared/navigation/main_shell.dart';

void main() {
  testWidgets('Mobile MainShell 3-tab footer + Shops Hub + Reports Hub render all sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('RenderFlex overflowed')) {
        oldOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getTheme(ThemeService().currentPreset),
        home: const MainShell(initialIndex: 0),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify bottom footer shows Home, Shops, Reports, Profile
    final bottomNav = find.byType(BottomNavigationBar);
    expect(find.descendant(of: bottomNav, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Shops')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Reports')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Profile')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Products')), findsNothing);
    expect(find.descendant(of: bottomNav, matching: find.text('Keywords')), findsNothing);

    // 1. Tap Shops footer -> opens Shops Hub (Shops / Products / Keywords)
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Shops')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Products'), findsAtLeastNWidgets(1));
    expect(find.text('Keywords'), findsAtLeastNWidgets(1));

    // Regression test: tap Shopify chip in Shops
    await tester.tap(find.widgetWithText(ChoiceChip, 'Shopify'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('nordichavenliving.com'), findsAtLeastNWidgets(1));

    // Tap Products sub-tab inside Shops Hub
    await tester.tap(find.text('Products').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Product Research'), findsAtLeastNWidgets(1));

    // Tap Keywords sub-tab inside Shops Hub
    await tester.tap(find.text('Keywords').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Keyword Research'), findsAtLeastNWidgets(1));

    // 2. Tap Reports footer -> opens Reports Hub (Reports / Competitors / Saved)
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Reports')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Reports'), findsAtLeastNWidgets(1));
    expect(find.text('Competitors'), findsAtLeastNWidgets(1));
    expect(find.text('Saved'), findsAtLeastNWidgets(1));

    // Tap Competitors sub-tab inside Reports Hub
    await tester.tap(find.text('Competitors').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Competitor Research'), findsAtLeastNWidgets(1));

    // Tap Saved sub-tab inside Reports Hub
    await tester.tap(find.text('Saved').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Saved Research'), findsAtLeastNWidgets(1));

    // 3. Tap Profile footer -> opens Profile
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Profile')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('User Profile'), findsAtLeastNWidgets(1));

    FlutterError.onError = oldOnError;
  });
}
