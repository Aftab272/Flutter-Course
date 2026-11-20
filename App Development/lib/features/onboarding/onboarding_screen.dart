import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/lootify_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.storefront_rounded,
      'title': 'Scrape Any E-Commerce Store',
      'highlight': 'Etsy, Amazon, eBay & Shopify',
      'description': 'Instantly parse public shop storefronts. Extract listing counts, average order values, estimated revenue, and top-performing keywords with one click.',
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'Discover High-Margin Products',
      'highlight': 'Algorithmic Opportunity Scoring',
      'description': 'Filter through thousands of items with our proprietary Opportunity Score (1-100). Uncover under-saturated niches before they become mainstream.',
    },
    {
      'icon': Icons.pie_chart_outline_rounded,
      'title': 'Outsmart Your Competitors',
      'highlight': 'Comparative Analytics Matrix',
      'description': 'Benchmark price disparities, catalog overlap, and customer sentiment to pinpoint weaknesses in competitor storefronts and capture market share.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeService().isLight;
    final bgColor = isLight ? Colors.white : AppColors.primaryBackground;
    final cardBg = isLight ? const Color(0xFFF8FAFC) : AppColors.secondaryBackground;
    final borderColor = isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor;
    final titleColor = isLight ? const Color(0xFF000000) : AppColors.primaryText;
    final descColor = isLight ? const Color(0xFF334155) : AppColors.secondaryText;
    final accentColor = isLight ? const Color(0xFF2563EB) : AppColors.accentLime;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: LootifyLogo(
            iconSize: 32,
            fontSize: 20,
            text: 'LootifyScrap',
            preferOfficialArtwork: true,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: isLight ? 'Switch to Dark Blue Theme' : 'Switch to White Theme',
            icon: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isLight ? const Color(0xFF000000) : Colors.white,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                ThemeService().togglePrimaryTheme();
              });
            },
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: isLight ? const Color(0xFF2563EB) : AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: (isLight ? const Color(0xFF2563EB) : AppColors.primaryGreen).withOpacity(0.12),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 52,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            page['highlight'] as String,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Text(
                            page['description'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: descColor,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Row(
                  children: [
                    if (_currentPage > 0) ...[
                      Expanded(
                        child: CustomButton(
                          text: 'Previous',
                          type: ButtonType.secondary,
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next Step',
                        type: ButtonType.primary,
                        icon: _currentPage == _pages.length - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
