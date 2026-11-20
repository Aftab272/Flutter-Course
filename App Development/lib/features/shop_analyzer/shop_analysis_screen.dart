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
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';

class ShopAnalysisScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopAnalysisScreen({super.key, required this.shop});

  @override
  State<ShopAnalysisScreen> createState() => _ShopAnalysisScreenState();
}

class _ShopAnalysisScreenState extends State<ShopAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();
  final ResearchService _researchService = ResearchService();
  final NumberFormat _currency = NumberFormat.compactSimpleCurrency();

  late ShopModel _currentShop;

  @override
  void initState() {
    super.initState();
    _currentShop = widget.shop;
    _tabController = TabController(length: 4, vsync: this);
    _shopService.addListener(_refreshState);
    _productService.addListener(_refreshState);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shopService.removeListener(_refreshState);
    _productService.removeListener(_refreshState);
    super.dispose();
  }

  void _refreshState() {
    final updated = _shopService.getShopById(_currentShop.id);
    if (updated != null && mounted) {
      setState(() => _currentShop = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final directProducts = _productService.getProductsForShop(_currentShop.id);
    final shopProducts = directProducts.isNotEmpty
        ? directProducts
        : _productService.allProducts
            .where((p) => p.marketplace.toLowerCase() == _currentShop.marketplace.toLowerCase())
            .take(12)
            .toList();
    final competitors = _researchService.competitors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_currentShop.name),
        actions: [
          IconButton(
            tooltip: _currentShop.isSaved ? 'Remove bookmark' : 'Bookmark shop',
            icon: Icon(
              _currentShop.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _currentShop.isSaved ? const Color(0xFF2563EB) : AppColors.adaptiveText,
            ),
            onPressed: () {
              _shopService.toggleSaveShop(_currentShop.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_currentShop.isSaved ? 'Shop saved to bookmarks!' : 'Shop removed from bookmarks.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Export Shop Analysis Report',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exported comprehensive SaaS report for "${_currentShop.name}"'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 28.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Header Profile
                    _buildShopHeader(context),
                    const SizedBox(height: 20),

                    // Metrics Row
                    _buildMetricsRow(isDesktop),
                    const SizedBox(height: 20),

                    // Badges & Categories
                    _buildBadgesAndTagsRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: const Color(0xFF2563EB),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF2563EB),
                  unselectedLabelColor: AppColors.adaptiveText,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  tabs: [
                    Tab(text: 'Listings (${shopProducts.isNotEmpty ? shopProducts.length : _currentShop.totalListings})'),
                    const Tab(text: 'Tags & Niches'),
                    const Tab(text: 'Competitor Overlap'),
                    const Tab(text: 'Strategic Report'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Product Listings
            _buildListingsTab(shopProducts),
            // Tab 2: Tags & Niches
            _buildTagsTab(),
            // Tab 3: Competitor Overlap
            _buildCompetitorsTab(competitors),
            // Tab 4: Strategic Report
            _buildStrategicReportTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            imageUrl: _currentShop.logoUrl,
            width: 72,
            height: 72,
            borderRadius: 12,
            fallbackIcon: Icons.storefront_rounded,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _currentShop.name,
                      style: TextStyle(
                        color: AppColors.adaptiveText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    MarketplaceBadge(marketplace: _currentShop.marketplace, isCompact: true),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black.withOpacity(0.22)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentShop.ownerAvatarUrl.isNotEmpty) ...[
                            CircleAvatar(
                              radius: 8,
                              backgroundImage: NetworkImage(_currentShop.ownerAvatarUrl),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            'Owner: ${_currentShop.ownerName}',
                            style: const TextStyle(color: Color(0xFF000000), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          _currentShop.rating.toStringAsFixed(2),
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.adaptiveText),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${NumberFormat.compact().format(_currentShop.reviewCount)} reviews)',
                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppColors.adaptiveText),
                        const SizedBox(width: 3),
                        Text(
                          _currentShop.country,
                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      'Est. ${_currentShop.openYear}',
                      style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _currentShop.description,
                  style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isDesktop ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricPill(
              width: cardWidth,
              label: 'Monthly Revenue Est.',
              value: _currency.format(_currentShop.monthlyRevenueEst),
              color: AppColors.adaptiveText,
              icon: Icons.monetization_on_outlined,
            ),
            _metricPill(
              width: cardWidth,
              label: 'Total Lifetime Sales',
              value: NumberFormat.compact().format(_currentShop.totalSales),
              color: AppColors.adaptiveText,
              icon: Icons.shopping_cart_checkout_rounded,
            ),
            _metricPill(
              width: cardWidth,
              label: 'Average Price Point',
              value: '\$${_currentShop.avgPrice.toStringAsFixed(2)}',
              color: AppColors.adaptiveText,
              icon: Icons.sell_outlined,
            ),
            _metricPill(
              width: cardWidth,
              label: 'Opportunity Score',
              value: '${_currentShop.opportunityScore}/100',
              color: AppColors.adaptiveText,
              icon: Icons.trending_up_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _metricPill({
    required double width,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesAndTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Store Badges:',
          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        ..._currentShop.badges.map((badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black.withOpacity(0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF2563EB)),
                  const SizedBox(width: 5),
                  Text(
                    badge,
                    style: const TextStyle(color: Color(0xFF000000), fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildListingsTab(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.adaptiveSubtext),
              const SizedBox(height: 16),
              Text(
                'Sample Listings Indexed',
                style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'This storefront contains ${_currentShop.totalListings} live listings on ${_currentShop.marketplace}.',
                style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Explore Similar Products in Research Hub',
                type: ButtonType.primary,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.productResearch),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = products[index];
        return CustomCard(
          padding: const EdgeInsets.all(14),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: p,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppNetworkImage(
                    imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                    width: 60,
                    height: 60,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.adaptiveText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${p.category} • Est. ${p.salesEstimate} monthly units',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ScoreIndicator(score: p.opportunityScore, size: 38, showLabel: false),
                ],
              ),
              const SizedBox(height: 10),
              // Horizontal price & saturation badges strictly inside the white card box
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black.withOpacity(0.22)),
                    ),
                    child: Text(
                      'Saturation: ${p.saturationLevel}',
                      style: const TextStyle(color: Color(0xFF000000), fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black.withOpacity(0.22)),
                    ),
                    child: Text(
                      'Score: ${p.opportunityScore}/100',
                      style: const TextStyle(color: Color(0xFF000000), fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'High-Frequency Ranking Tags',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Keywords used repeatedly across this shop’s listings with high search algorithm conversion.',
            style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentShop.topTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.22)),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(color: Color(0xFF000000), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            'Store Category Distribution',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ..._currentShop.topCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat, style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('Top Grossing', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 6,
                      backgroundColor: AppColors.secondaryBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompetitorsTab(List<dynamic> competitors) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: competitors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comp = competitors[index];
        return CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      comp.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.adaptiveText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MarketplaceBadge(marketplace: comp.marketplace, isCompact: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comp.strengthSummary,
                style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    'Price Advantage: ${comp.priceAdvantage > 0 ? "+" : ""}${comp.priceAdvantage}%',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Catalog Overlap: ${comp.overlapPercentage}%',
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStrategicReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algorithmic Storefront Review & SWOT',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _swotCard(
            title: 'Core Advantages & Strengths',
            color: AppColors.adaptiveText,
            iconColor: const Color(0xFF2563EB),
            icon: Icons.check_circle_outline_rounded,
            points: [
              'Consistent organic SEO keywords driving 68% of storefront traffic without paid ads.',
              'High customer feedback rating (${_currentShop.rating}/5.0) builds instant consumer trust.',
              'Healthy average order value (\$${_currentShop.avgPrice.toStringAsFixed(2)}) provides strong fulfillment buffer.',
            ],
          ),
          const SizedBox(height: 14),
          _swotCard(
            title: 'Storefront Vulnerabilities & Market Opportunities',
            color: AppColors.adaptiveText,
            iconColor: const Color(0xFF2563EB),
            icon: Icons.lightbulb_outline_rounded,
            points: [
              'Competitors are under-cutting pricing on entry-level accessories by 8-12%.',
              'Bundle opportunities (e.g. 3-packs, complete kits) are under-utilized in this catalog.',
              'Expand into international localized sizing and translations for +22% estimated revenue uplift.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _swotCard({
    required String title,
    required Color color,
    required Color iconColor,
    required IconData icon,
    required List<String> points,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 14)),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.14)),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

