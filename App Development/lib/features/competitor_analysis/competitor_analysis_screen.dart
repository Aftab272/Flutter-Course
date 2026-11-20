import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/demo_data.dart';
import '../../models/competitor_model.dart';
import '../../models/shop_model.dart';
import '../../services/product_service.dart';
import '../../services/research_service.dart';
import '../../services/shop_service.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/score_indicator.dart';

class CompetitorAnalysisScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CompetitorAnalysisScreen({super.key, this.onNavigateTab});

  @override
  State<CompetitorAnalysisScreen> createState() => _CompetitorAnalysisScreenState();
}

class _CompetitorAnalysisScreenState extends State<CompetitorAnalysisScreen> {
  final ResearchService _researchService = ResearchService();
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMarketplace = 'All';

  String? _selectedBaseShopId;
  String? _selectedCompetitorId;

  @override
  void initState() {
    super.initState();
    if (_shopService.shops.isNotEmpty) {
      _selectedBaseShopId = _shopService.shops.first.id;
    }
    if (_researchService.competitors.isNotEmpty) {
      _selectedCompetitorId = _researchService.competitors.first.id;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCompetitorDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String mkt = 'Etsy';

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: theme.cardTheme.color ?? AppColors.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              title: Text(
                'Track New Competitor Store',
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Competitor Store Name',
                      hintText: 'e.g. Apex Rival Studio',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Storefront URL',
                      hintText: 'https://...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: mkt,
                    dropdownColor: theme.cardTheme.color ?? AppColors.secondaryBackground,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(labelText: 'Marketplace'),
                    items: ['Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => mkt = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                CustomButton(
                  text: 'Add to Monitor',
                  type: ButtonType.primary,
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final newComp = CompetitorModel(
                        id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        marketplace: mkt,
                        url: urlCtrl.text.trim().isNotEmpty ? urlCtrl.text.trim() : 'https://$mkt.com/store',
                        rating: 4.8,
                        salesCount: 15400,
                        priceAdvantage: -6.5,
                        monthlyRevenueEst: 38000.0,
                        overlapPercentage: 70,
                        strengthSummary: 'Automated monitoring initialized via competitive tracker.',
                        weakPoints: ['New competitor added for tracking'],
                        topCategories: ['General'],
                        productCount: 85,
                      );
                      _researchService.addCompetitor(newComp);
                      setState(() {
                        _selectedCompetitorId = newComp.id;
                        _searchQuery = newComp.name;
                        _searchController.text = newComp.name;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Competitor "${newComp.name}" added to tracking successfully!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final allCompetitors = _researchService.competitors;
    final shops = _shopService.shops;

    // Filter competitors by search query and marketplace
    final filteredCompetitors = allCompetitors.where((c) {
      if (_selectedMarketplace != 'All' && c.marketplace.toLowerCase() != _selectedMarketplace.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(query);
        final matchesMarket = c.marketplace.toLowerCase().contains(query);
        final matchesCat = c.topCategories.any((cat) => cat.toLowerCase().contains(query));
        final matchesStrength = c.strengthSummary.toLowerCase().contains(query);
        if (!matchesName && !matchesMarket && !matchesCat && !matchesStrength) {
          return false;
        }
      }
      return true;
    }).toList();

    // The active competitor being inspected in detail
    final activeCompetitor = allCompetitors.firstWhere(
      (c) => c.id == _selectedCompetitorId,
      orElse: () => filteredCompetitors.isNotEmpty
          ? filteredCompetitors.first
          : (allCompetitors.isNotEmpty ? allCompetitors.first : DemoData.initialCompetitors.first),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Competitor Research & Benchmarking',
                      style: TextStyle(
                        color: AppColors.adaptiveText,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search competitors, inspect actual listings, catalog overlap, and pricing disparity.',
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13),
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Track New Store',
                  icon: Icons.add_rounded,
                  type: ButtonType.primary,
                  onPressed: _showAddCompetitorDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Competitor Search Bar
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search competitor by store name, marketplace, or niche keyword...',
                    prefixIcon: Icons.search_rounded,
                    suffix: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                        // If exact match found, select it
                        final match = allCompetitors.firstWhere(
                          (c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
                          orElse: () => activeCompetitor,
                        );
                        _selectedCompetitorId = match.id;
                      });
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reset'),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Marketplace Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                  final isSelected = _selectedMarketplace == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      checkmarkColor: Colors.white,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (m != 'All') ...[
                            BrandIcon(brand: m.toLowerCase(), size: 14),
                            const SizedBox(width: 6),
                          ],
                          Text(m == 'All' ? 'All Platforms' : m),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMarketplace = m);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ACTIVE COMPETITOR FULL DETAILS SECTION
            _buildActiveCompetitorDetails(activeCompetitor, isDesktop),
            const SizedBox(height: 28),

            // Head-to-Head Comparison Card
            _buildHeadToHeadSection(shops, allCompetitors, isDesktop),
            const SizedBox(height: 28),

            // Monitored Competitors Directory
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monitored Competitors (${filteredCompetitors.length} of ${allCompetitors.length})',
                  style: TextStyle(
                    color: AppColors.adaptiveText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (filteredCompetitors.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.store_mall_directory_outlined, size: 48, color: AppColors.adaptiveSubtext),
                      const SizedBox(height: 12),
                      Text(
                        'No competitors found matching "$_searchQuery"',
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try searching by a different name, or click "Track New Store" above to add it.',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildCompetitorCardsGrid(filteredCompetitors, isDesktop),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Complete details of the selected competitor: profile, metrics, and actual products listed
  Widget _buildActiveCompetitorDetails(CompetitorModel comp, bool isDesktop) {
    final theme = Theme.of(context);
    final cardBg = theme.cardTheme.color ?? AppColors.secondaryBackground;

    // Find products from or related to this competitor
    final relatedProducts = _productService.allProducts.where((p) {
      return p.marketplace.toLowerCase() == comp.marketplace.toLowerCase() ||
          p.shopName.toLowerCase().contains(comp.name.toLowerCase());
    }).take(4).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? Colors.black.withOpacity(0.24)
              : theme.dividerColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: const Text(
                    'COMPETITOR INTELLIGENCE PROFILE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              MarketplaceBadge(
                marketplace: comp.marketplace,
                targetUrl: comp.url,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Competitor Title & Stats Banner
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Center(
                  child: BrandIcon(brand: comp.marketplace.toLowerCase(), size: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comp.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                            const SizedBox(width: 3),
                            Text(
                              '${comp.rating} ★',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comp.strengthSummary,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _metricBadge('Monthly Revenue', '\$${comp.monthlyRevenueEst.toInt()}/mo', AppColors.adaptiveText),
                        _metricBadge('Catalog Overlap', '${comp.overlapPercentage}%', AppColors.adaptiveText),
                        _metricBadge(
                          'Price Advantage',
                          '${comp.priceAdvantage > 0 ? "+" : ""}${comp.priceAdvantage}%',
                          AppColors.adaptiveText,
                        ),
                        _metricBadge('Indexed Products', '${comp.productCount} items', AppColors.adaptiveText),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 16),

          // Actual Products Listed by Competitor Store
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Available Listings from ${comp.name} (${relatedProducts.length} items)',
                style: TextStyle(
                  color: AppColors.adaptiveText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              OutlinedButton.icon(
                icon: BrandIcon(brand: comp.marketplace.toLowerCase(), size: 14),
                label: Text('Open on ${comp.marketplace}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.adaptiveText,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.black.withOpacity(0.22)),
                ),
                onPressed: () {
                  UrlLauncherHelper.openUrl(comp.url);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (relatedProducts.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = isDesktop ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: relatedProducts.map((p) {
                    return SizedBox(
                      width: itemWidth > 180 ? itemWidth : constraints.maxWidth,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.productDetails, arguments: p);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppNetworkImage(
                                imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                                width: double.infinity,
                                height: 110,
                                borderRadius: 8,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.adaptiveText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  ScoreIndicator(score: p.opportunityScore, size: 28),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }

  Widget _buildHeadToHeadSection(List<ShopModel> shops, List<CompetitorModel> competitors, bool isDesktop) {
    final theme = Theme.of(context);
    final baseShop = shops.firstWhere(
      (s) => s.id == _selectedBaseShopId,
      orElse: () => shops.isNotEmpty ? shops.first : DemoData.initialShops.first,
    );
    final comp = competitors.firstWhere(
      (c) => c.id == _selectedCompetitorId,
      orElse: () => competitors.isNotEmpty ? competitors.first : DemoData.initialCompetitors.first,
    );

    final currentBaseId = shops.any((s) => s.id == _selectedBaseShopId)
        ? _selectedBaseShopId
        : (shops.isNotEmpty ? shops.first.id : null);

    final currentCompId = competitors.any((c) => c.id == _selectedCompetitorId)
        ? _selectedCompetitorId
        : (competitors.isNotEmpty ? competitors.first.id : null);

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: Color(0xFF2563EB), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Head-to-Head Storefront Comparison',
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Responsive Selectors (Stacked cleanly on mobile so text never leaves the dropdown box!)
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentBaseId,
                    isExpanded: true,
                    dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                    decoration: const InputDecoration(labelText: 'Your Baseline Store'),
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w600),
                    items: shops.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text('${s.name} (${s.marketplace})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBaseShopId = val);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text('VS', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w900)),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentCompId,
                    isExpanded: true,
                    dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                    decoration: const InputDecoration(labelText: 'Target Competitor Store'),
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w600),
                    items: competitors.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text('${c.name} (${c.marketplace})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCompetitorId = val);
                    },
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: currentBaseId,
                  isExpanded: true,
                  dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                  decoration: const InputDecoration(labelText: 'Your Baseline Store'),
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w600),
                  items: shops.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.id,
                      child: Text('${s.name} (${s.marketplace})', maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBaseShopId = val);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text('VS', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: currentCompId,
                  isExpanded: true,
                  dropdownColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                  decoration: const InputDecoration(labelText: 'Target Competitor Store'),
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w600),
                  items: competitors.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text('${c.name} (${c.marketplace})', maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCompetitorId = val);
                  },
                ),
              ],
            ),
          const SizedBox(height: 20),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 16),

          // Metrics comparison (Stacked cleanly on mobile, side-by-side on desktop)
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _storeComparisonColumn(
                    name: baseShop.name,
                    marketplace: baseShop.marketplace,
                    rating: baseShop.rating,
                    revenue: '\$${baseShop.monthlyRevenueEst.toInt()}/mo',
                    avgPrice: '\$${baseShop.avgPrice.toStringAsFixed(2)}',
                    listings: '${baseShop.totalListings} items',
                    isBase: true,
                    isMobile: false,
                  ),
                ),
                Container(width: 1, height: 140, color: theme.dividerColor),
                Expanded(
                  child: _storeComparisonColumn(
                    name: comp.name,
                    marketplace: comp.marketplace,
                    rating: comp.rating,
                    revenue: '\$${comp.monthlyRevenueEst.toInt()}/mo',
                    avgPrice: comp.priceAdvantage < 0
                        ? 'Base -${comp.priceAdvantage.abs()}%'
                        : 'Base +${comp.priceAdvantage}%',
                    listings: '${comp.productCount} items',
                    isBase: false,
                    isMobile: false,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _storeComparisonColumn(
                  name: baseShop.name,
                  marketplace: baseShop.marketplace,
                  rating: baseShop.rating,
                  revenue: '\$${baseShop.monthlyRevenueEst.toInt()}/mo',
                  avgPrice: '\$${baseShop.avgPrice.toStringAsFixed(2)}',
                  listings: '${baseShop.totalListings} items',
                  isBase: true,
                  isMobile: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: theme.dividerColor),
                ),
                _storeComparisonColumn(
                  name: comp.name,
                  marketplace: comp.marketplace,
                  rating: comp.rating,
                  revenue: '\$${comp.monthlyRevenueEst.toInt()}/mo',
                  avgPrice: comp.priceAdvantage < 0
                      ? 'Base -${comp.priceAdvantage.abs()}%'
                      : 'Base +${comp.priceAdvantage}%',
                  listings: '${comp.productCount} items',
                  isBase: false,
                  isMobile: true,
                ),
              ],
            ),
          const SizedBox(height: 18),

          // Analysis banner (Clean icon color + soft black border)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.insights_rounded, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Catalog Overlap is ${comp.overlapPercentage}%. Competitor ${comp.priceAdvantage < 0 ? "undercuts your pricing by ${comp.priceAdvantage.abs()}%" : "prices items ${comp.priceAdvantage}% higher than baseline"}. ${comp.strengthSummary}',
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeComparisonColumn({
    required String name,
    required String marketplace,
    required double rating,
    required String revenue,
    required String avgPrice,
    required String listings,
    required bool isBase,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2.0 : 16.0),
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : (isBase ? CrossAxisAlignment.start : CrossAxisAlignment.end),
        children: [
          Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : (isBase ? MainAxisAlignment.start : MainAxisAlignment.end),
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.adaptiveText),
                ),
              ),
              const SizedBox(width: 8),
              MarketplaceBadge(marketplace: marketplace, isCompact: true),
            ],
          ),
          const SizedBox(height: 10),
          _compRow('Rating', '$rating ★', isBase, isMobile: isMobile),
          _compRow('Monthly Revenue Est.', revenue, isBase, isMobile: isMobile),
          _compRow('Pricing Advantage', avgPrice, isBase, isMobile: isMobile),
          _compRow('Catalog Size', listings, isBase, isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _compRow(String label, String value, bool isBase, {bool isMobile = false}) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: isBase ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBase) ...[
            Text('$label: ', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12)),
            Text(value, style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w800)),
          ] else ...[
            Text(value, style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w800)),
            Text(' :$label', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildCompetitorCardsGrid(List<CompetitorModel> competitors, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isDesktop ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: competitors.map((c) {
            final isSelected = c.id == _selectedCompetitorId;
            return SizedBox(
              width: cardWidth,
              child: CustomCard(
                padding: const EdgeInsets.all(18),
                onTap: () {
                  setState(() => _selectedCompetitorId = c.id);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF9333EA),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              c.name,
                              style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        MarketplaceBadge(marketplace: c.marketplace),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.strengthSummary,
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderColor),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catalog Overlap', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11)),
                            Text('${c.overlapPercentage}%', style: const TextStyle(color: AppColors.accentLime, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price Disparity', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11)),
                            Text(
                              '${c.priceAdvantage > 0 ? "+" : ""}${c.priceAdvantage}%',
                              style: TextStyle(
                                color: c.priceAdvantage < 0 ? AppColors.accentLime : AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Revenue Est.', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11)),
                            Text('\$${c.monthlyRevenueEst.toInt()}/mo', style: TextStyle(color: AppColors.adaptiveText, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: isSelected ? 'Currently Inspected Above' : 'Inspect Competitor Details',
                      type: isSelected ? ButtonType.primary : ButtonType.secondary,
                      isFullWidth: true,
                      onPressed: () {
                        setState(() {
                          _selectedCompetitorId = c.id;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
