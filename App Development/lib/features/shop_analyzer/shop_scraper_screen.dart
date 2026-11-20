import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../services/shop_service.dart';
import '../../services/product_service.dart';
import '../../services/research_service.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';

class ShopScraperScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const ShopScraperScreen({super.key, this.onNavigateTab});

  @override
  State<ShopScraperScreen> createState() => _ShopScraperScreenState();
}

class _ShopScraperScreenState extends State<ShopScraperScreen> {
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();
  final ResearchService _researchService = ResearchService();
  final TextEditingController _urlController = TextEditingController();

  String _selectedMarketplace = 'Etsy';
  bool _isScraping = false;
  ShopModel? _lastScrapedShop;
  ProductModel? _lastScrapedProduct;
  int _scrapedProductSelectedImage = 0;
  String _scrapingStep = '';

  final Map<String, List<String>> _sampleUrls = {
    'Etsy': [
      'https://etsy.com/shop/BohoAestheticStudio',
      'https://etsy.com/listing/142981729/minimalist-ceramic-wabi-sabi-vase',
      'https://etsy.com/shop/LeatherCraftsmanCo',
    ],
    'Amazon': [
      'https://amazon.com/shops/ApexTacticalGear',
      'https://amazon.com/dp/B08N5WRWNW',
      'https://amazon.com/shops/LuminaGlowWellness',
    ],
    'eBay': [
      'https://ebay.com/usr/RetroTechVault',
      'https://ebay.com/itm/234918274910',
      'https://ebay.com/usr/SneakerVaultDirect',
    ],
    'Shopify': [
      'https://nordichavenliving.com',
      'https://nordichavenliving.com/products/scandi-minimalist-desk-mat',
      'https://veloxactive.com',
    ],
  };

  @override
  void initState() {
    super.initState();
    _urlController.text = _sampleUrls['Etsy']?.firstOrNull ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onMarketplaceSelected(String marketplace) {
    setState(() {
      _selectedMarketplace = marketplace;
      _urlController.text = _sampleUrls[marketplace]?.firstOrNull ?? '';
    });
  }

  bool _isProductUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/listing/') ||
        lower.contains('/dp/') ||
        lower.contains('/gp/product/') ||
        lower.contains('/itm/') ||
        lower.contains('/products/') ||
        lower.contains('/product/') ||
        lower.contains('/item/');
  }

  void _runScraper() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid shop or product URL')),
      );
      return;
    }

    final isProduct = _isProductUrl(url);

    setState(() {
      _isScraping = true;
      _scrapingStep = isProduct
          ? 'Connecting to $_selectedMarketplace product API & extracting mockups...'
          : 'Connecting to $_selectedMarketplace public storefront endpoints...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _scrapingStep = isProduct
          ? 'Extracting high-res image angles, pricing history & reviews...'
          : 'Extracting product listings, pricing & reviews...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _scrapingStep = 'Calculating opportunity scores & locating competitor cross-listings...');

    final result = await _shopService.scrapeUrl(
      url: url,
      defaultMarketplace: _selectedMarketplace,
    );

    final targetProduct = result.product;
    final targetShop = result.shop;

    _researchService.addActivity(
      result.isProductUrl
          ? 'Scraped product & cross-listings for ${targetProduct?.title ?? targetShop.name}'
          : 'Scraped & indexed ${targetShop.name} (${targetShop.marketplace})',
    );

    if (!mounted) return;
    setState(() {
      _isScraping = false;
      _lastScrapedShop = targetShop;
      _lastScrapedProduct = targetProduct;
      _scrapedProductSelectedImage = 0;
      _scrapingStep = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isProductUrl
              ? 'Product "${targetProduct?.title}" & Storefront "${targetShop.name}" extracted successfully!'
              : 'Storefront "${targetShop.name}" parsed successfully! (${result.shopProducts.length} listings indexed)',
        ),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

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
            // Header
            Text(
              'Shop Scraper & Storefront Analyzer',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter any public store or product URL from Etsy, Amazon, eBay, or Shopify to scrape listings, inspect mockups, and discover all related competitor stores.',
              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13.5),
            ),
            const SizedBox(height: 24),

            // Scraper Control Card
            CustomCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 1: Select Marketplace',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Marketplace Pill Selector (Blue boxes with White text)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                      final isSelected = _selectedMarketplace == m;
                      return ChoiceChip(
                        checkmarkColor: Colors.white,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BrandIcon(brand: m.toLowerCase(), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              m,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1D4ED8),
                        backgroundColor: const Color(0xFF2563EB),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF2563EB),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (selected) {
                          if (selected) _onMarketplaceSelected(m);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Step 2: Enter Public Shop or Product URL',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _urlController,
                    hintText: 'Paste shop or product link (e.g. https://etsy.com/shop/... or /listing/...)',
                    prefixIcon: Icons.link_rounded,
                    suffix: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Sample URL Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Presets:',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                      ),
                      ...(_sampleUrls[_selectedMarketplace] ?? []).map((sample) {
                        final isProd = _isProductUrl(sample);
                        final uri = Uri.tryParse(sample);
                        final segments = uri?.pathSegments.where((s) => s.isNotEmpty).toList() ?? [];
                        final label = segments.isNotEmpty
                            ? segments.last
                            : ((uri != null && uri.host.isNotEmpty) ? uri.host : sample);
                        final displayLabel = label.length > 22 ? '${label.substring(0, 20)}...' : label;
                        return ActionChip(
                          avatar: Icon(
                            isProd ? Icons.inventory_2_outlined : Icons.storefront_outlined,
                            size: 14,
                            color: const Color(0xFF2563EB),
                          ),
                          label: Text(
                            isProd ? 'Product: $displayLabel' : 'Shop: $displayLabel',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.adaptiveText,
                            ),
                          ),
                          backgroundColor: AppColors.adaptiveSurface,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          onPressed: () {
                            setState(() => _urlController.text = sample);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Scrape Action Button
                  SizedBox(
                    width: isDesktop ? 260 : double.infinity,
                    child: CustomButton(
                      text: _isScraping ? 'Scraping Data...' : 'Scrape & Analyze URL',
                      icon: Icons.radar_rounded,
                      type: ButtonType.primary,
                      isLoading: _isScraping,
                      onPressed: _runScraper,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // In-Progress Live Feedback
            if (_isScraping) ...[
              CustomCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: AppColors.secondaryBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentLime),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _scrapingStep,
                      style: TextStyle(
                        color: AppColors.adaptiveText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Extracting listings • Parsing price distributions • Detecting cross-marketplace stores',
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // CASE 1: PRODUCT LINK WAS SCRAPED
            if (_lastScrapedProduct != null && !_isScraping) ...[
              _buildScrapedProductShowcaseCard(_lastScrapedProduct!),
              const SizedBox(height: 24),
              // Cross-Platform Product Listings
              _buildCrossPlatformListingsSection(_lastScrapedProduct!),
              const SizedBox(height: 24),
              // Related Stores selling this product / in this niche
              _buildRelatedShopsForProduct(_lastScrapedProduct!),
              const SizedBox(height: 24),
              // Remaining products from the storefront
              if (_lastScrapedShop != null) ...[
                _buildScrapedProductsSection(
                  _lastScrapedShop!,
                  title: 'Other Listings from ${_lastScrapedShop!.name}',
                ),
                const SizedBox(height: 28),
              ],
            ]
            // CASE 2: SHOP LINK WAS SCRAPED
            else if (_lastScrapedShop != null && !_isScraping) ...[
              _buildScrapedShopBanner(_lastScrapedShop!),
              const SizedBox(height: 20),
              _buildPlatformIsolationMetrics(_lastScrapedShop!),
              const SizedBox(height: 20),
              _buildScrapedProductsSection(_lastScrapedShop!),
              const SizedBox(height: 24),
              _buildRelatedCompetitorShopsForShop(_lastScrapedShop!),
              const SizedBox(height: 28),
            ],

            // All Analyzed Stores Table/List
            _buildAnalyzedShopsList(),
          ],
        ),
      ),
    );
  }

  /// Scraped Product Showcase with mockups, all image gallery, pricing, tags, and direct launch
  Widget _buildScrapedProductShowcaseCard(ProductModel product) {
    final images = product.imageUrls.isNotEmpty ? product.imageUrls : [''];
    final safeIndex = _scrapedProductSelectedImage < images.length ? _scrapedProductSelectedImage : 0;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : (theme.cardTheme.color ?? AppColors.secondaryBackground),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? Colors.black.withOpacity(0.22) : theme.dividerColor,
          width: 1.2,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: Text(
                  'PRODUCT INTELLIGENCE EXTRACTED',
                  style: TextStyle(
                    color: AppColors.adaptiveText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              // Clickable Marketplace Badge (opens live platform)
              MarketplaceBadge(
                marketplace: product.marketplace,
                isCompact: true,
                targetUrl: UrlLauncherHelper.getMarketplaceUrl(product.marketplace, query: product.title),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Mockup + Gallery
                Expanded(
                  flex: 4,
                  child: _buildProductGalleryWidget(images, safeIndex, product),
                ),
                const SizedBox(width: 24),
                // Right: Product Details & Metrics
                Expanded(
                  flex: 6,
                  child: _buildProductDetailsRightWidget(product),
                ),
              ],
            )
          else ...[
            _buildProductGalleryWidget(images, safeIndex, product),
            const SizedBox(height: 18),
            _buildProductDetailsRightWidget(product),
          ],
        ],
      ),
    );
  }

  Widget _buildProductGalleryWidget(List<String> images, int safeIndex, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Active Mockup
        Stack(
          children: [
            AppNetworkImage(
              imageUrl: images[safeIndex],
              height: 260,
              width: double.infinity,
              borderRadius: 12,
              fallbackIcon: Icons.shopping_bag_outlined,
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mockup ${safeIndex + 1} of ${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          // Thumbnails
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = safeIndex == idx;
                return InkWell(
                  onTap: () => setState(() => _scrapedProductSelectedImage = idx),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppColors.accentLime : AppColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: AppNetworkImage(
                      imageUrl: images[idx],
                      width: 54,
                      height: 54,
                      borderRadius: 5,
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

  Widget _buildProductDetailsRightWidget(ProductModel product) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store and Owner Name strictly inside box via Wrap
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.ownerAvatarUrl.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 11,
                    backgroundImage: NetworkImage(product.ownerAvatarUrl),
                  ),
                  const SizedBox(width: 6),
                ] else ...[
                  const Icon(Icons.storefront_rounded, size: 15, color: Color(0xFF2563EB)),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    'Storefront: ${product.shopName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (product.ownerName.isNotEmpty)
              Text(
                '• Owner: ${product.ownerName}',
                style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // Title
        Text(
          product.title,
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        // Listing date and media indicator strictly inside box via Wrap
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.adaptiveText),
                const SizedBox(width: 5),
                Text(
                  'Listing Date: ${product.createdAt.year}-${product.createdAt.month.toString().padLeft(2, '0')}-${product.createdAt.day.toString().padLeft(2, '0')}',
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, size: 13, color: Color(0xFF2563EB)),
                const SizedBox(width: 4),
                Text(
                  product.imageUrls.isNotEmpty ? 'Original Media Loaded' : 'Direct Link Extracted',
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Pricing & Score Row (Solid Black price!)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    product.price > 0 ? '\$${product.price.toStringAsFixed(2)}' : 'See Live Price',
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (product.originalPrice != null && product.originalPrice! > product.price)
                    Text(
                      '\$${product.originalPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.adaptiveSubtext,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
            ScoreIndicator(score: product.opportunityScore, size: 40),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.borderColor),
        const SizedBox(height: 10),

        // Key stats
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _statItem('Est. Monthly Sales', '${product.salesEstimate} units/mo'),
            _statItem('Est. Monthly Revenue', '\$${product.monthlyRevenue.toInt()}/mo'),
            _statItem('Rating & Reviews', '${product.rating} ★ (${product.reviewCount})'),
            _statItem('Saturation', product.saturationLevel),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          product.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5, height: 1.4),
        ),
        const SizedBox(height: 12),

        // Tags (White boxes with solid Black text)
        if (product.tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: product.tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: Text(
                  '#$t',
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),

        // Action Buttons: Direct Platform Visit + Deep Dive
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              icon: BrandIcon(brand: product.marketplace.toLowerCase(), size: 16),
              label: Text('Open on ${product.marketplace} (Direct Live Link)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final inputUrl = _urlController.text.trim();
                final url = inputUrl.isNotEmpty && (inputUrl.startsWith('http://') || inputUrl.startsWith('https://'))
                    ? inputUrl
                    : UrlLauncherHelper.getMarketplaceUrl(
                        product.marketplace,
                        query: product.title,
                      );
                UrlLauncherHelper.openUrl(url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${product.title} directly on ${product.marketplace}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.insights_rounded, size: 16),
              label: const Text('View Deep Intelligence'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                side: const BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: product,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Cross-Platform Product Listings (Amazon, eBay, Etsy & Shopify)
  Widget _buildCrossPlatformListingsSection(ProductModel product) {
    final allProducts = _productService.allProducts;
    final crossMatches = allProducts.where((p) {
      if (p.id == product.id) return false;
      if (p.marketplace.toLowerCase() == product.marketplace.toLowerCase()) return false;
      final matchesCat = p.category.toLowerCase() == product.category.toLowerCase();
      final matchesTag = p.tags.any((t) => product.tags.contains(t));
      return matchesCat || matchesTag;
    }).take(4).toList();

    if (crossMatches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_rounded, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cross-Platform Product Listings (${crossMatches.length} Found Across Marketplaces)',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Original product listings, mockups, and merchant details identified across Amazon, eBay, Shopify, and Etsy.',
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossMatches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final p = crossMatches[index];
            return CustomCard(
              padding: const EdgeInsets.all(14),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.productDetails, arguments: p);
              },
              child: Row(
                children: [
                  AppNetworkImage(
                    imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                    width: 60,
                    height: 60,
                    borderRadius: 8,
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
                                  color: AppColors.adaptiveText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MarketplaceBadge(
                              marketplace: p.marketplace,
                              isCompact: true,
                              targetUrl: UrlLauncherHelper.getMarketplaceUrl(p.marketplace, query: p.title),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Seller: ${p.shopName}',
                              style: const TextStyle(color: AppColors.accentLime, fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Owner: ${p.ownerName}',
                              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Listed: ${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}',
                              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accentLime,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ScoreIndicator(score: p.opportunityScore, size: 28),
                    ],
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: BrandIcon(brand: p.marketplace.toLowerCase(), size: 14),
                    label: Text('Open on ${p.marketplace}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      side: const BorderSide(color: AppColors.borderColor),
                    ),
                    onPressed: () {
                      UrlLauncherHelper.openUrl(
                        UrlLauncherHelper.getMarketplaceUrl(p.marketplace, query: p.title),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Displays related shops carrying similar products
  Widget _buildRelatedShopsForProduct(ProductModel product) {
    final relatedShops = _shopService.getRelatedShops(
      category: product.category,
      excludeShopId: product.shopId,
      limit: 4,
    );
    if (relatedShops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront_rounded, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 8),
            Text(
              'Other Stores Carrying Similar Products (${relatedShops.length} Stores Across Marketplaces)',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Competitor stores across Etsy, Amazon, eBay, and Shopify where this item or similar niche inventory is listed.',
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
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
              child: Row(
                children: [
                  AppNetworkImage(
                    imageUrl: s.logoUrl,
                    width: 48,
                    height: 48,
                    borderRadius: 8,
                    fallbackIcon: Icons.store_mall_directory_rounded,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.name,
                              style: TextStyle(
                                color: AppColors.adaptiveText,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MarketplaceBadge(
                              marketplace: s.marketplace,
                              isCompact: true,
                              targetUrl: s.url,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${s.country} • ${s.totalListings} items listed • ★ ${s.rating.toStringAsFixed(1)}',
                          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${s.monthlyRevenueEst.toInt()}/mo',
                        style: const TextStyle(
                          color: AppColors.accentLime,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text('Est. Revenue', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 10.5)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.chevron_right_rounded, color: AppColors.adaptiveSubtext, size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScrapedShopBanner(ShopModel shop) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : (theme.cardTheme.color ?? AppColors.secondaryBackground),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight ? Colors.black.withOpacity(0.22) : theme.dividerColor,
          width: 1.2,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: Text(
                  'STOREFRONT SCRAPED & INDEXED',
                  style: TextStyle(
                    color: AppColors.adaptiveText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              MarketplaceBadge(
                marketplace: shop.marketplace,
                isCompact: true,
                targetUrl: shop.url,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AppNetworkImage(
                imageUrl: shop.logoUrl,
                width: 60,
                height: 60,
                borderRadius: 12,
                fallbackIcon: Icons.storefront_rounded,
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
                            shop.name,
                            style: TextStyle(
                              color: AppColors.adaptiveText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (shop.ownerAvatarUrl.isNotEmpty) ...[
                                CircleAvatar(
                                  radius: 8,
                                  backgroundImage: NetworkImage(shop.ownerAvatarUrl),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                'Owner: ${shop.ownerName}',
                                style: const TextStyle(color: AppColors.accentLime, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Listing/Open Date: ${shop.listingDate} • ${shop.country} • ${shop.totalListings} Original Products Listed',
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 16,
                children: [
                  _statItem('Rating', '${shop.rating} ★'),
                  _statItem('Total Sales', '${shop.totalSales}'),
                  _statItem('Est. Revenue', '\$${shop.monthlyRevenueEst.toInt()}/mo'),
                  _statItem('Listings', '${shop.totalListings} items'),
                ],
              ),
              Wrap(
                spacing: 10,
                children: [
                  OutlinedButton.icon(
                    icon: BrandIcon(brand: shop.marketplace.toLowerCase(), size: 14),
                    label: Text('Open on ${shop.marketplace}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      side: const BorderSide(color: AppColors.borderColor),
                    ),
                    onPressed: () {
                      UrlLauncherHelper.openUrl(shop.url);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${shop.name} live on ${shop.marketplace}...'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  CustomButton(
                    text: 'View Full Analysis',
                    icon: Icons.analytics_outlined,
                    type: ButtonType.lime,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.shopAnalysis,
                        arguments: shop,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformIsolationMetrics(ShopModel shop) {
    final theme = Theme.of(context);
    final targetMkt = shop.marketplace.toLowerCase();
    final platforms = [
      {'name': 'Etsy', 'brand': 'etsy'},
      {'name': 'Shopify', 'brand': 'shopify'},
      {'name': 'Amazon', 'brand': 'amazon'},
      {'name': 'eBay', 'brand': 'ebay'},
    ];

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cross-Marketplace Isolation Matrix (100% Authentic Seller Data)',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ACTIVE: ${shop.marketplace.toUpperCase()}',
                  style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'In accordance with seller isolation guidelines, only the verified active marketplace displays confirmed store listings and sales. Unconnected platforms display 0.',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.65), fontSize: 12),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final cards = platforms.map((p) {
                final isMatch = (p['brand'] as String) == targetMkt;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isMatch ? AppColors.primaryGreen.withOpacity(0.08) : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMatch ? AppColors.primaryGreen : theme.dividerColor,
                      width: isMatch ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BrandIcon(brand: p['brand'] as String, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            p['name'] as String,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMatch ? AppColors.primaryGreen : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isMatch ? 'ACTIVE' : '0 DATA',
                              style: TextStyle(
                                color: isMatch ? Colors.white : AppColors.adaptiveSubtext,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Listings:', style: TextStyle(fontSize: 11.5, color: AppColors.adaptiveSubtext)),
                          Text(
                            isMatch ? '${shop.totalListings}' : '0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isMatch ? theme.colorScheme.onSurface : AppColors.adaptiveSubtext,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Confirmed Orders:', style: TextStyle(fontSize: 11.5, color: AppColors.adaptiveSubtext)),
                          Text(
                            isMatch ? '${shop.totalSales}' : '0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isMatch ? theme.colorScheme.onSurface : AppColors.adaptiveSubtext,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Revenue Est.:', style: TextStyle(fontSize: 11.5, color: AppColors.adaptiveSubtext)),
                          Text(
                            isMatch ? '\$${shop.monthlyRevenueEst.toInt()}/mo' : '\$0.00',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isMatch ? AppColors.accentLime : AppColors.adaptiveSubtext,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isMatch ? '✓ Verified Source: ${shop.url}' : 'Not connected on this marketplace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: isMatch ? FontStyle.normal : FontStyle.italic,
                          color: isMatch ? AppColors.primaryGreen : AppColors.adaptiveSubtext.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              if (isWide) {
                return Row(
                  children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: c))).toList(),
                );
              } else {
                return Column(
                  children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10.0), child: c)).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrapedProductsSection(ShopModel shop, {String? title}) {
    final products = _productService.getProductsForShop(shop.id);
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 8),
            Text(
              title ?? 'Extracted Live Listings & Products (${products.length})',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Full Shop Analysis'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.shopAnalysis,
                  arguments: shop,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Live scraped inventory parsed from public storefront with sales estimates, pricing, and keyword rankings.',
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = products[index];
            return CustomCard(
              padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppNetworkImage(
                        imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                        width: 76,
                        height: 76,
                        borderRadius: 10,
                        fallbackIcon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    p.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.adaptiveText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.accentLime,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (p.originalPrice != null)
                                      Text(
                                        '\$${p.originalPrice!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.adaptiveSubtext,
                                          fontSize: 11.5,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.adaptiveSubtext,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderColor),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Wrap(
                        spacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _miniStat('Sales', '${p.salesEstimate}/mo'),
                          _miniStat('Revenue', '\$${p.monthlyRevenue.toInt()}/mo'),
                          _miniStat('Rating', '${p.rating} ★ (${p.reviewCount})'),
                          _miniStat('Opp Score', '${p.opportunityScore}/100'),
                        ],
                      ),
                      const Spacer(),
                      // Direct platform open button
                      IconButton(
                        tooltip: 'Open listing on ${p.marketplace}',
                        icon: BrandIcon(brand: p.marketplace.toLowerCase(), size: 16),
                        onPressed: () {
                          final url = UrlLauncherHelper.getMarketplaceUrl(p.marketplace, query: p.title);
                          UrlLauncherHelper.openUrl(url);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${p.title} on ${p.marketplace}...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.insights_rounded, size: 14),
                        label: const Text('View Product', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                            arguments: p,
                          );
                        },
                      ),
                    ],
                  ),
                  if (p.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: AppColors.adaptiveSubtext,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRelatedCompetitorShopsForShop(ShopModel shop) {
    final relatedShops = _shopService.getRelatedShops(
      category: shop.topCategories.firstOrNull,
      excludeShopId: shop.id,
      limit: 3,
    );
    if (relatedShops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.compare_arrows_rounded, color: AppColors.accentLime, size: 20),
            const SizedBox(width: 8),
            Text(
              'Competitor Stores in this Niche',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Top competing storefronts selling similar products across Etsy, Amazon, eBay, and Shopify.',
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
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
              child: Row(
                children: [
                  AppNetworkImage(
                    imageUrl: s.logoUrl,
                    width: 46,
                    height: 46,
                    borderRadius: 8,
                    fallbackIcon: Icons.store_mall_directory_rounded,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.name,
                              style: TextStyle(
                                color: AppColors.adaptiveText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MarketplaceBadge(
                              marketplace: s.marketplace,
                              isCompact: true,
                              targetUrl: s.url,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${s.country} • ${s.totalListings} listings • ★ ${s.rating.toStringAsFixed(1)}',
                          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\$${s.monthlyRevenueEst.toInt()}/mo',
                    style: const TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: AppColors.adaptiveSubtext, size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.adaptiveText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzedShopsList() {
    final shops = _shopService.shops;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analyzed Storefront Database (${shops.length})',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shops.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final s = shops[index];
            return CustomCard(
              padding: const EdgeInsets.all(14),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.shopAnalysis,
                  arguments: s,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Logo + Shop Name/Info + Favourite Icon (strictly inside box) + Arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: s.logoUrl,
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
                              '${s.country} • ${s.totalListings} listings',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.adaptiveSubtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favourite Icon inside the main box: White when unselected, changes color (Red/Blue) when tapped!
                      InkWell(
                        onTap: () {
                          setState(() {
                            _shopService.toggleSaveShop(s.id);
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: s.isSaved ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            s.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.adaptiveSubtext),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: Solid Black Revenue + Marketplace Link Badge (strictly inside main box, zero overflow!)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '\$${s.monthlyRevenueEst.toInt()}/mo',
                        style: TextStyle(
                          color: AppColors.adaptiveText,
                          fontSize: 14,
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
}
