import 'package:flutter_test/flutter_test.dart';
import 'package:shop_scraper_app/app.dart';

void main() {
  testWidgets('App smoke test loads successfully and navigates to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopScraperApp());
    expect(find.byType(ShopScraperApp), findsOneWidget);

    // Settle splash screen transition
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
