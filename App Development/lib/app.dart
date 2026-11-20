import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/demo_data.dart';
import 'models/shop_model.dart';
import 'models/product_model.dart';
import 'services/theme_service.dart';
import 'shared/navigation/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/authentication/login_screen.dart';
import 'features/authentication/registration_screen.dart';
import 'features/shop_analyzer/marketplace_selection_screen.dart';
import 'features/shop_analyzer/shop_analysis_screen.dart';
import 'features/product_details/product_details_screen.dart';
import 'features/saved_research/saved_products_screen.dart';
import 'features/saved_research/saved_shops_screen.dart';
import 'features/settings/settings_screen.dart';

class ShopScraperApp extends StatelessWidget {
  const ShopScraperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        final currentPreset = ThemeService().currentPreset;
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(currentPreset),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegistrationScreen(),
            AppRoutes.mainShell: (context) => const MainShell(),
            AppRoutes.dashboard: (context) => const MainShell(initialIndex: 0),
            AppRoutes.shopScraper: (context) => const MainShell(initialIndex: 1),
            AppRoutes.productResearch: (context) => const MainShell(initialIndex: 2),
            AppRoutes.keywordResearch: (context) => const MainShell(initialIndex: 3),
            AppRoutes.competitorAnalysis: (context) => const MainShell(initialIndex: 4),
            AppRoutes.reports: (context) => const MainShell(initialIndex: 6),
            AppRoutes.profile: (context) => const MainShell(initialIndex: 7),
            AppRoutes.marketplaceSelection: (context) => const MarketplaceSelectionScreen(),
            AppRoutes.savedProducts: (context) => const SavedProductsScreen(isStandalone: true),
            AppRoutes.savedShops: (context) => const SavedShopsScreen(isStandalone: true),
            AppRoutes.settings: (context) => const SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.shopAnalysis) {
              final shop = settings.arguments is ShopModel
                  ? settings.arguments as ShopModel
                  : DemoData.initialShops.first;
              return MaterialPageRoute(
                builder: (context) => ShopAnalysisScreen(shop: shop),
              );
            }
            if (settings.name == AppRoutes.productDetails) {
              final product = settings.arguments is ProductModel
                  ? settings.arguments as ProductModel
                  : DemoData.initialProducts.first;
              return MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
