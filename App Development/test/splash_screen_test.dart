import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_scraper_app/core/routes/app_routes.dart';
import 'package:shop_scraper_app/features/splash/splash_screen.dart';
import 'package:shop_scraper_app/shared/widgets/lootify_logo.dart';

void main() {
  testWidgets('SplashScreen plays 3-second zoom-out animation and navigates cleanly', (WidgetTester tester) async {
    bool navigatedToLogin = false;

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) {
            navigatedToLogin = true;
            return const Scaffold(body: Center(child: Text('Login Screen')));
          },
          AppRoutes.mainShell: (_) => const Scaffold(body: Center(child: Text('Main Shell'))),
        },
      ),
    );

    // Logo is centered immediately on launch
    expect(find.byType(LootifyLogo), findsOneWidget);
    final scaleFinder = find.ancestor(
      of: find.byType(LootifyLogo),
      matching: find.byType(ScaleTransition),
    );
    expect(scaleFinder, findsOneWidget);

    // At t = 0s, scale starts zoomed-in (1.32x)
    final initialScale = tester.widget<ScaleTransition>(scaleFinder).scale.value;
    expect(initialScale, greaterThan(1.25));

    // At t = 1.5s, scale is smoothly zooming out toward 1.0x and still on SplashScreen
    await tester.pump(const Duration(milliseconds: 1500));
    final midScale = tester.widget<ScaleTransition>(scaleFinder).scale.value;
    expect(midScale, lessThan(initialScale));
    expect(midScale, greaterThanOrEqualTo(1.0));
    expect(navigatedToLogin, isFalse);

    // At t = 2.8s, still on SplashScreen (not navigated early)
    await tester.pump(const Duration(milliseconds: 1300));
    expect(navigatedToLogin, isFalse);

    // At t = 3.0s+, animation completes and automatically navigates
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(navigatedToLogin, isTrue);
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
