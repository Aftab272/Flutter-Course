import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../services/shop_service.dart';
import '../../services/product_service.dart';
import '../../services/research_service.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';
import '../../shared/widgets/lootify_logo.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();
  final ResearchService _researchService = ResearchService();
  final NumberFormat _currencyFormat = NumberFormat.compactSimpleCurrency();

  @override
  void initState() {
    super.initState();
    _shopService.addListener(_onStateChange);
    _productService.addListener(_onStateChange);
    _researchService.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _shopService.removeListener(_onStateChange);
    _productService.removeListener(_onStateChange);
    _researchService.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    final shops = _shopService.shops;
    final products = _productService.allProducts;
    final savedProductsCount = _productService.totalSavedProductsCount;
    final savedShopsCount = _shopService.savedShops.length;

    // Calculate aggregated revenue analyzed
    double totalAnalyzedRevenue = 0;
    for (var s in shops) {
      totalAnalyzedRevenue += s.monthlyRevenueEst;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header & Quick Action Banner
            _buildHeaderBanner(context, isDesktop),
            const SizedBox(height: 24),

            // SaaS Metric Cards Grid
            _buildMetricsGrid(
              shops.length,
              products.length,
              savedProductsCount + savedShopsCount,
              totalAnalyzedRevenue,
              isDesktop,
              isTablet,
            ),
            const SizedBox(height: 28),

            // Platform-wise Research Overview
            _buildPlatformOverview(isDesktop),
            const SizedBox(height: 28),

            // Split Section: Recent Shop Analysis + Top Opportunity Products
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildRecentShopsSection(shops),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: _buildTopProductsSection(products),
                  ),
                ],
              )
            else ...[
              _buildRecentShopsSection(shops),
              const SizedBox(height: 28),
              _buildTopProductsSection(products),
            ],
            const SizedBox(height: 28),

            // Recent Activity Feed
            _buildActivityLogSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
        gradient: LinearGradient(
          colors: [
            cardBg,
            primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Official Lootify Scrap logo + App Name directly beside it (Requirement 22B)
                    const LootifyLogo(
                      iconSize: 28,
                      fontSize: 18,
                      showText: true,
                      text: 'Lootify Scrap',
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE MULTI-MARKETPLACE INTELLIGENCE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome Back, ${_researchService.user.name}',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Automated research feeds are monitoring 4 marketplaces. Explore new listings or analyze a competitor shop below.',
                  style: TextStyle(
                    color: ThemeService().isLight ? const Color(0xFF000000) : onSurface.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: ThemeService().isLight ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            Wrap(
              spacing: 10,
              children: [
                CustomButton(
                  text: 'Analyze Shop',
                  icon: Icons.search_rounded,
                  type: ButtonType.primary,
                  onPressed: () => widget.onNavigateTab?.call(1),
                ),
                CustomButton(
                  text: 'Explore Products',
                  icon: Icons.inventory_2_outlined,
                  type: ButtonType.secondary,
                  onPressed: () => widget.onNavigateTab?.call(2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    int totalShops,
    int totalProducts,
    int totalSaved,
    double totalRevenue,
    bool isDesktop,
    bool isTablet,
  ) {
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    final metrics = [
      MetricCard(
        title: 'Analyzed Shops',
        value: '$totalShops Stores',
        subtitle: 'Across 4 marketplaces',
        trend: '+18.4% this mo',
        icon: Icons.storefront_rounded,
        onTap: () => widget.onNavigateTab?.call(1),
      ),
      MetricCard(
        title: 'Researched Products',
        value: '$totalProducts Items',
        subtitle: 'High conversion catalog',
        trend: '+34 new today',
        icon: Icons.inventory_2_outlined,
        onTap: () => widget.onNavigateTab?.call(2),
      ),
      MetricCard(
        title: 'Saved Research',
        value: '$totalSaved Bookmarks',
        subtitle: 'Shops & top products',
        trend: 'Active watchlists',
        icon: Icons.bookmark_added_rounded,
        onTap: () => widget.onNavigateTab?.call(5),
      ),
      MetricCard(
        title: 'Tracked Revenue Est.',
        value: _currencyFormat.format(totalRevenue),
        subtitle: 'Monthly gross GMV',
        trend: '+22.1% market avg',
        valueColor: AppColors.adaptiveText,
        icon: Icons.monetization_on_outlined,
        onTap: () => widget.onNavigateTab?.call(6),
      ),
    ];

    if (crossAxisCount == 1) {
      return Column(
        children: metrics.map((m) => Padding(padding: const EdgeInsets.only(bottom: 12), child: m)).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.7 : 2.0,
      children: metrics,
    );
  }

  Widget _buildPlatformOverview(bool isDesktop) {
    final platforms = _researchService.platformStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Marketplace Research Matrix',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeService().isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
              label: const Text(
                'View All',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.marketplaceSelection),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: platforms.map((p) {
                return SizedBox(
                  width: cardWidth > 200 ? cardWidth : constraints.maxWidth,
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () {
                      _productService.setMarketplace(p.marketplace);
                      widget.onNavigateTab?.call(2);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MarketplaceBadge(marketplace: p.marketplace),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                const SizedBox(width: 3),
                                Text(
                                  p.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${p.analyzedCount} Shops Analyzed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.adaptiveText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.topCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.adaptiveSubtext,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currencyFormat.format(p.totalRevenueAnalyzed),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.adaptiveText,
                              ),
                            ),
                            Text(
                              '+${p.growthRate}% MoM',
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentShopsSection(List<ShopModel> shops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Shop Analysis',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateTab?.call(1),
              child: const Text('Scrape New Shop'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shops.take(4).length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final shop = shops[index];
            return CustomCard(
              padding: const EdgeInsets.all(14),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.shopAnalysis,
                  arguments: shop,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: shop.logoUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 10,
                        fallbackIcon: Icons.store_mall_directory_rounded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.adaptiveText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '★ ${shop.rating.toStringAsFixed(1)} • ${NumberFormat.compact().format(shop.totalSales)} sales • ${shop.totalListings} listings',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.adaptiveSubtext,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          shop.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: shop.isSaved ? const Color(0xFF2563EB) : AppColors.adaptiveText,
                          size: 20,
                        ),
                        onPressed: () => _shopService.toggleSaveShop(shop.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${_currencyFormat.format(shop.monthlyRevenueEst)}/mo est.',
                        style: TextStyle(
                          color: AppColors.adaptiveText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      MarketplaceBadge(
                        marketplace: shop.marketplace,
                        isCompact: true,
                        targetUrl: shop.url,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopProductsSection(List<ProductModel> products) {
    final sorted = List<ProductModel>.from(products)
      ..sort((a, b) => b.opportunityScore.compareTo(a.opportunityScore));

    // Pick 1 distinct top-opportunity product per marketplace (Etsy, Amazon, eBay, Shopify)
    final List<ProductModel> topList = [];
    final Set<String> seenTitles = {};
    for (final m in ['Etsy', 'Amazon', 'eBay', 'Shopify']) {
      for (final p in sorted) {
        if (p.marketplace.toLowerCase() == m.toLowerCase() && !seenTitles.contains(p.title)) {
          topList.add(p);
          seenTitles.add(p.title);
          break;
        }
      }
    }
    for (final p in sorted) {
      if (topList.length >= 4) break;
      if (!seenTitles.contains(p.title)) {
        topList.add(p);
        seenTitles.add(p.title);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'High Opportunity Products',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.adaptiveText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateTab?.call(2),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topList.take(4).length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final prod = topList[index];
            return CustomCard(
              padding: const EdgeInsets.all(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: prod,
                );
              },
              child: Row(
                children: [
                  AppNetworkImage(
                    imageUrl: prod.imageUrls.isNotEmpty ? prod.imageUrls.first : '',
                    width: 50,
                    height: 50,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.adaptiveText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '\$${prod.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: ThemeService().isLight ? const Color(0xFF000000) : AppColors.accentLime,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MarketplaceBadge(marketplace: prod.marketplace, isCompact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScoreIndicator(score: prod.opportunityScore, size: 36, showLabel: false),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityLogSection() {
    final logs = _researchService.activityLog;

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Recent Research Activity',
                style: TextStyle(
                  color: AppColors.adaptiveText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 10),
          Column(
            children: logs.take(5).map((log) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentLime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log,
                        style: TextStyle(
                          color: AppColors.adaptiveSubtext,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

