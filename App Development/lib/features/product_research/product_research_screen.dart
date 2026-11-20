import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';
import '../../services/theme_service.dart';

class ProductResearchScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProductResearchScreen({super.key, this.onNavigateTab});

  @override
  State<ProductResearchScreen> createState() => _ProductResearchScreenState();
}

class _ProductResearchScreenState extends State<ProductResearchScreen> {
  final ProductService _productService = ProductService();
  final ThemeService _themeService = ThemeService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = _productService.searchQuery;
    _productService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _productService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      _productService.setSearchQuery(val);
    });
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _showFilterBottomSheet(BuildContext context) {
    final isLight = _themeService.isLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? Colors.white : AppColors.secondaryBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Products & Niches',
                        style: TextStyle(
                          color: isLight ? const Color(0xFF000000) : AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _productService.resetFilters();
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  Divider(color: isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor),
                  const SizedBox(height: 12),

                  // Marketplace Filter
                  Text(
                    'Marketplace',
                    style: TextStyle(
                      color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All Marketplaces', 'Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                      final isSelected = _productService.selectedMarketplace == m;
                      return ChoiceChip(
                        label: Text(m),
                        selected: isSelected,
                        selectedColor: isLight ? const Color(0xFF2563EB) : AppColors.primaryGreen,
                        backgroundColor: isLight ? const Color(0xFFFFFFFF) : AppColors.primaryBackground,
                        side: BorderSide(
                          color: isSelected
                              ? (isLight ? const Color(0xFF2563EB) : AppColors.primaryGreen)
                              : (isLight ? const Color(0xFFCBD5E1) : AppColors.borderColor),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            _productService.setMarketplace(m);
                            setSheetState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Saturation Filter
                  Text(
                    'Saturation Level',
                    style: TextStyle(
                      color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Low', 'Medium', 'High'].map((sat) {
                      final isSelected = _productService.selectedSaturation == sat;
                      return ChoiceChip(
                        label: Text(sat),
                        selected: isSelected,
                        selectedColor: isLight ? const Color(0xFF2563EB) : AppColors.accentLime,
                        backgroundColor: isLight ? const Color(0xFFFFFFFF) : AppColors.primaryBackground,
                        side: BorderSide(
                          color: isSelected
                              ? (isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                              : (isLight ? const Color(0xFFCBD5E1) : AppColors.borderColor),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isLight ? Colors.white : Colors.black)
                              : (isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            _productService.setSaturation(sat);
                            setSheetState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Price Range Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max Price Filter',
                        style: TextStyle(
                          color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '\$${_productService.maxPrice.toInt()}',
                        style: TextStyle(
                          color: isLight ? const Color(0xFF2563EB) : AppColors.accentLime,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _productService.maxPrice,
                    min: 20.0,
                    max: 300.0,
                    divisions: 14,
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: AppColors.borderColor,
                    onChanged: (val) {
                      _productService.setPriceRange(0, val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Apply Filters',
                    type: ButtonType.primary,
                    isFullWidth: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
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
    final products = _productService.filteredProducts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = isDesktop ? 28.0 : 16.0;
          int crossAxisCount = 1;
          final gridWidth = constraints.maxWidth - (hPad * 2);
          if (gridWidth >= 1100) {
            crossAxisCount = 3;
          } else if (gridWidth >= 650) {
            crossAxisCount = 2;
          }

          return CustomScrollView(
            cacheExtent: 600,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 20.0, hPad, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            // Page Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Research & Opportunity Engine',
                        style: TextStyle(
                          color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover winning e-commerce products with automated demand & saturation analysis.',
                        style: TextStyle(
                          color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                          fontSize: 13,
                          fontWeight: _themeService.isLight ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop)
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Grid View',
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: _isGridView
                              ? (_themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                              : (_themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                        ),
                        onPressed: () => setState(() => _isGridView = true),
                      ),
                      IconButton(
                        tooltip: 'List View',
                        icon: Icon(
                          Icons.view_list_rounded,
                          color: !_isGridView
                              ? (_themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                              : (_themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                        ),
                        onPressed: () => setState(() => _isGridView = false),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Filters Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search products by title, tag, keyword, or store name...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: _onSearchChanged,
                    suffix: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _productService.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                CustomButton(
                  text: 'Filters',
                  icon: Icons.tune_rounded,
                  type: ButtonType.secondary,
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Chips Bar & Sort Dropdown
            _buildQuickFilterBar(),
            const SizedBox(height: 20),

            // Results Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${products.length} products matching criteria',
                  style: TextStyle(
                    color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_productService.searchQuery.isNotEmpty ||
                    _productService.selectedMarketplace != 'All Marketplaces' ||
                    _productService.selectedSaturation != 'All')
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      _productService.resetFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        color: _themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
                ),
              ),

              // Virtualized Products Grid / List (60+ FPS for 4,000+ items)
              if (products.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  sliver: SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: 'No Matching Products Found',
                      message: 'Try adjusting your search keywords, price sliders, or selected marketplace filters.',
                      actionText: 'Reset Filters',
                      onAction: () {
                        _searchController.clear();
                        _productService.resetFilters();
                      },
                    ),
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 382,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(products[index]),
                      childCount: products.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildProductListTile(products[index]),
                      ),
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickFilterBar() {
    final isLight = _themeService.isLight;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Marketplace quick tabs
          ...['All Marketplaces', 'Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
            final isSelected = _productService.selectedMarketplace == m;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(m),
                selected: isSelected,
                selectedColor: isLight ? const Color(0xFF2563EB) : AppColors.primaryGreen,
                backgroundColor: isLight ? const Color(0xFFFFFFFF) : AppColors.secondaryBackground,
                side: BorderSide(
                  color: isSelected
                      ? (isLight ? const Color(0xFF2563EB) : AppColors.primaryGreen)
                      : (isLight ? const Color(0xFFCBD5E1) : AppColors.borderColor),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                onSelected: (_) => _productService.setMarketplace(m),
              ),
            );
          }),
          const SizedBox(width: 8),
          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFFFFFFF) : AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLight ? const Color(0xFFCBD5E1) : AppColors.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductSortOption>(
                value: _productService.sortOption,
                dropdownColor: isLight ? Colors.white : AppColors.secondaryBackground,
                style: TextStyle(
                  color: isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                icon: Icon(
                  Icons.sort_rounded,
                  size: 16,
                  color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                ),
                items: const [
                  DropdownMenuItem(
                    value: ProductSortOption.highestOpportunity,
                    child: Text('Highest Opportunity Score'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.priceLowToHigh,
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.priceHighToLow,
                    child: Text('Price: High to Low'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.mostReviews,
                    child: Text('Most Reviews'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.newest,
                    child: Text('Newest Listings'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) _productService.setSortOption(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    return CustomCard(
      padding: EdgeInsets.zero,
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
          // Image Container with Badges
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                height: 168,
                width: double.infinity,
                borderRadius: 12,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: MarketplaceBadge(marketplace: p.marketplace),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      p.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: p.isSaved ? AppColors.accentLime : Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _productService.toggleSaveProduct(p.id),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    p.stockStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${p.shopName} • ${p.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                    fontSize: 11.5,
                    fontWeight: _themeService.isLight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _themeService.isLight ? const Color(0xFF000000) : AppColors.accentLime,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (p.originalPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${p.originalPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _themeService.isLight ? const Color(0xFF475569) : AppColors.secondaryText,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    ScoreIndicator(score: p.opportunityScore, size: 36, showLabel: false),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 3),
                    Text(
                      p.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${p.reviewCount})',
                      style: TextStyle(
                        fontSize: 11,
                        color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                        fontWeight: _themeService.isLight ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '~${p.salesEstimate}/mo sales',
                      style: TextStyle(
                        fontSize: 11,
                        color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListTile(ProductModel p) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: p,
        );
      },
      child: Row(
            children: [
              AppNetworkImage(
                imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                width: 76,
                height: 76,
                borderRadius: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MarketplaceBadge(marketplace: p.marketplace, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.shopName} • ${p.category} • Saturation: ${p.saturationLevel}',
                      style: TextStyle(
                        color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                        fontSize: 12,
                        fontWeight: _themeService.isLight ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _themeService.isLight ? const Color(0xFF000000) : AppColors.accentLime,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '~${p.salesEstimate} monthly units (\$${p.monthlyRevenue.toInt()}/mo)',
                          style: TextStyle(
                            color: _themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                            fontSize: 12,
                            fontWeight: _themeService.isLight ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ScoreIndicator(score: p.opportunityScore, size: 42),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  p.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: p.isSaved
                      ? (_themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                      : (_themeService.isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                ),
                onPressed: () => _productService.toggleSaveProduct(p.id),
              ),
            ],
          ),
        );
  }
}

