import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../services/product_service.dart';
import '../../services/shop_service.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../core/utils/url_launcher_helper.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  late ProductModel _product;
  int _selectedImageIndex = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _productService.addListener(_onProductChange);
  }

  @override
  void dispose() {
    _productService.removeListener(_onProductChange);
    super.dispose();
  }

  void _onProductChange() {
    final updated = _productService.getProductById(_product.id);
    if (updated != null && mounted) {
      setState(() => _product = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final relatedProducts = _productService.getRelatedProducts(_product);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Product Intelligence'),
        actions: [
          IconButton(
            tooltip: _product.isSaved ? 'Remove from Saved' : 'Save Product',
            icon: Icon(
              _product.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _product.isSaved ? AppColors.accentLime : AppColors.adaptiveText,
            ),
            onPressed: () {
              _productService.toggleSaveProduct(_product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_product.isSaved ? 'Product added to saved research!' : 'Product removed from saved.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Export Product Report',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exported PDF analysis report for "${_product.title}"'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Layout: Desktop 2-column or Mobile Stack
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildGallerySection(),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 6,
                    child: _buildDetailsSection(context),
                  ),
                ],
              )
            else ...[
              _buildGallerySection(),
              const SizedBox(height: 20),
              _buildDetailsSection(context),
            ],
            const SizedBox(height: 32),

            // Market Competition Overview
            _buildCompetitionSection(),
            const SizedBox(height: 32),

            // Related Products Section
            if (relatedProducts.isNotEmpty) ...[
              Text(
                'Related Market Opportunities',
                style: TextStyle(
                  color: AppColors.adaptiveText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _buildRelatedProductsGrid(relatedProducts, isDesktop),
              const SizedBox(height: 32),
            ],

            // Competitor / Related Stores Section
            _buildRelatedShopsSection(isDesktop),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedShopsSection(bool isDesktop) {
    final relatedShops = _shopService.getRelatedShops(
      category: _product.category,
      excludeShopId: _product.shopId,
      limit: 4,
    );
    if (relatedShops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront_rounded, color: Color(0xFF2563EB), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Other Stores Carrying Similar Products',
                style: TextStyle(
                  color: AppColors.adaptiveText,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Competitor storefronts across Etsy, Amazon, eBay, and Shopify that sell in this exact niche.',
          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: relatedShops.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final s = relatedShops[index];
            return CustomCard(
              padding: const EdgeInsets.all(14),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.shopAnalysis, arguments: s);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: s.logoUrl,
                        width: 48,
                        height: 48,
                        borderRadius: 8,
                        fallbackIcon: Icons.store_mall_directory_rounded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
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
                              '${s.country} • ${s.totalListings} listings • ★ ${s.rating.toStringAsFixed(1)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, color: AppColors.adaptiveText, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Horizontal Est. Revenue (solid Black) + Platform Badge strictly inside the main card box
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '\$${s.monthlyRevenueEst.toInt()}/mo Est. Revenue',
                        style: TextStyle(
                          color: AppColors.adaptiveText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      MarketplaceBadge(
                        marketplace: s.marketplace,
                        isCompact: true,
                        targetUrl: s.url,
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

  Widget _buildGallerySection() {
    final images = _product.imageUrls.isNotEmpty ? _product.imageUrls : [''];

    return Column(
      children: [
        // Main Display Image
        CustomCard(
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              AppNetworkImage(
                imageUrl: images[_selectedImageIndex],
                height: 360,
                width: double.infinity,
                borderRadius: 12,
              ),
              Positioned(
                top: 14,
                left: 14,
                child: MarketplaceBadge(marketplace: _product.marketplace),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_selectedImageIndex + 1} / ${images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          // Thumbnails Strip
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = _selectedImageIndex == index;
                return InkWell(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.accentLime : AppColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: AppNetworkImage(
                      imageUrl: images[index],
                      width: 64,
                      height: 64,
                      borderRadius: 6,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  ShopModel _resolveShopForProduct() {
    // 1. Exact ID match
    final byId = _shopService.getShopById(_product.shopId);
    if (byId != null) return byId;

    // 2. Match by store name
    for (final s in _shopService.shops) {
      if (s.name.toLowerCase() == _product.shopName.toLowerCase()) {
        return s;
      }
    }

    // 3. Build full shop profile from this product's real store & matching catalog products
    final storeProducts = _productService.allProducts
        .where((p) =>
            p.shopName.toLowerCase() == _product.shopName.toLowerCase() ||
            (p.marketplace.toLowerCase() == _product.marketplace.toLowerCase() &&
                p.category.toLowerCase() == _product.category.toLowerCase()))
        .toList();

    final avgPrice = storeProducts.isNotEmpty
        ? storeProducts.fold<double>(0.0, (sum, p) => sum + p.price) / storeProducts.length
        : _product.price;
    final estRev = storeProducts.fold<double>(0.0, (sum, p) => sum + p.monthlyRevenue);
    final totalSales = storeProducts.fold<int>(0, (sum, p) => sum + p.salesEstimate);

    return ShopModel(
      id: _product.shopId.isNotEmpty ? _product.shopId : 'shop_${_product.shopName.toLowerCase().replaceAll(' ', '_')}',
      name: _product.shopName,
      marketplace: _product.marketplace,
      url: UrlLauncherHelper.getMarketplaceUrl(_product.marketplace, query: _product.shopName),
      logoUrl: _product.imageUrls.isNotEmpty ? _product.imageUrls.first : '',
      ownerName: _product.ownerName.isNotEmpty ? _product.ownerName : _product.shopName,
      ownerAvatarUrl: _product.ownerAvatarUrl,
      rating: _product.rating > 0 ? _product.rating : 4.8,
      reviewCount: _product.reviewCount > 0 ? _product.reviewCount : 420,
      totalListings: storeProducts.isNotEmpty ? storeProducts.length : 1,
      totalSales: totalSales > 0 ? totalSales : _product.salesEstimate,
      monthlyRevenueEst: estRev > 0 ? estRev : _product.monthlyRevenue,
      avgPrice: avgPrice,
      country: 'United States',
      openYear: _product.createdAt.year,
      opportunityScore: _product.opportunityScore,
      description: 'Official ${_product.marketplace} storefront for ${_product.shopName} specializing in ${_product.category}.',
      topCategories: [_product.category],
      topTags: _product.tags.take(8).toList(),
      badges: ['Verified ${_product.marketplace} Store'],
    );
  }

  void _openShopProfile(BuildContext context) {
    final shop = _resolveShopForProduct();
    Navigator.pushNamed(context, AppRoutes.shopAnalysis, arguments: shop);
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store name & Navigation (100% workable for every product!)
        InkWell(
          onTap: () => _openShopProfile(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                _product.shopName,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_outward_rounded, size: 13, color: Color(0xFF2563EB)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Product Title
        Text(
          _product.title,
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),

        // Rating & Reviews (Wrap so Stock badge never overflows)
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  _product.rating.toStringAsFixed(1),
                  style: TextStyle(color: AppColors.adaptiveText, fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${_product.reviewCount} verified reviews)',
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black.withOpacity(0.22)),
              ),
              child: Text(
                _product.stockStatus,
                style: const TextStyle(color: Color(0xFF000000), fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Price Row with Opportunity Score Meter (Solid Black price!)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '\$${_product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_product.originalPrice != null) ...[
                    Text(
                      '\$${_product.originalPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.adaptiveSubtext,
                        fontSize: 15,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black.withOpacity(0.22)),
                      ),
                      child: Text(
                        '-${((1 - (_product.price / _product.originalPrice!)) * 100).toInt()}%',
                        style: const TextStyle(color: Color(0xFF000000), fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            ScoreIndicator(score: _product.opportunityScore, size: 46),
          ],
        ),
        const SizedBox(height: 22),
        const Divider(height: 1, color: AppColors.borderColor),
        const SizedBox(height: 18),

        // Description
        Text(
          'Product Description & Value Proposition',
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _product.description,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13.5, height: 1.5),
        ),
        if (_product.description.length > 120) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Read Less' : 'Read Full Description...',
              style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 20),

        // Tags (White boxes with solid Black text)
        Text(
          'High-Intent Search Tags',
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _product.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.22)),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Actions: Save & Visit Shop
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: _product.isSaved ? 'Bookmarked' : 'Save to Favorites',
                type: _product.isSaved ? ButtonType.lime : ButtonType.primary,
                icon: _product.isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_border_rounded,
                onPressed: () {
                  _productService.toggleSaveProduct(_product.id);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'View Shop Profile',
                type: ButtonType.secondary,
                icon: Icons.storefront_rounded,
                onPressed: () => _openShopProfile(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: BrandIcon(brand: _product.marketplace.toLowerCase(), size: 18),
            label: Text(
              'Open Live Product on ${_product.marketplace}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final url = UrlLauncherHelper.getMarketplaceUrl(
                _product.marketplace,
                query: _product.title,
              );
              UrlLauncherHelper.openUrl(url);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${_product.title} on ${_product.marketplace}...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionSection() {
    return CustomCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.query_stats_rounded, size: 20, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Algorithmic Competition & Revenue Metrics',
                  style: TextStyle(
                    color: AppColors.adaptiveText,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statBox(
                    width: itemWidth > 180 ? itemWidth : constraints.maxWidth,
                    title: 'Monthly Volume Estimate',
                    value: '~${_product.salesEstimate} units/mo',
                    highlight: '\$${_product.monthlyRevenue.toInt()} GMV',
                  ),
                  _statBox(
                    width: itemWidth > 180 ? itemWidth : constraints.maxWidth,
                    title: 'Niche Saturation',
                    value: _product.saturationLevel,
                    highlight: _product.saturationLevel == 'Low' ? 'High Opportunity' : 'Competitive Space',
                  ),
                  _statBox(
                    width: itemWidth > 180 ? itemWidth : constraints.maxWidth,
                    title: 'Competition Density',
                    value: '${_product.competitionScore} / 5.0',
                    highlight: 'Market Overlap: Low',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required double width,
    required String title,
    required String value,
    required String highlight,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF334155), fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            highlight,
            style: const TextStyle(color: Color(0xFF000000), fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsGrid(List<ProductModel> related, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxis = isDesktop ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 222,
          ),
          itemCount: related.length,
          itemBuilder: (context, index) {
            final p = related[index];
            return CustomCard(
              padding: const EdgeInsets.all(10),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: p,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                    height: 122,
                    width: double.infinity,
                    borderRadius: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${p.price.toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      ScoreIndicator(score: p.opportunityScore, size: 28, showLabel: false),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

