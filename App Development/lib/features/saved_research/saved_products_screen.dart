import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/score_indicator.dart';

class SavedProductsScreen extends StatefulWidget {
  final bool isStandalone;

  const SavedProductsScreen({super.key, this.isStandalone = false});

  @override
  State<SavedProductsScreen> createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  final ProductService _productService = ProductService();
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _productService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _productService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saved = _productService.savedProducts.where((p) {
      if (_searchFilter.isEmpty) return true;
      return p.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.marketplace.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          p.shopName.toLowerCase().contains(_searchFilter.toLowerCase());
    }).toList();

    Widget content;
    if (_productService.savedProducts.isEmpty) {
      content = EmptyStateWidget(
        icon: Icons.bookmark_border_rounded,
        title: 'No Saved Products Yet',
        message: 'Bookmark high-margin items during your product research to build your watchlists and track competitors.',
        actionText: 'Browse High Opportunity Products',
        onAction: () => Navigator.pushNamed(context, AppRoutes.productResearch),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search in saved
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search within saved products...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchFilter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() => _searchFilter = ''),
                    )
                  : null,
            ),
            onChanged: (val) => setState(() => _searchFilter = val),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: saved.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = saved[index];
              return CustomCard(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.productDetails, arguments: p);
                },
                child: Row(
                  children: [
                    AppNetworkImage(
                      imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                      width: 64,
                      height: 64,
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
                            '${p.shopName} • \$${p.price.toStringAsFixed(2)} • ~${p.salesEstimate} sales/mo',
                            style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ScoreIndicator(score: p.opportunityScore, size: 36, showLabel: false),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Remove bookmark',
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      onPressed: () {
                        _productService.toggleSaveProduct(p.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed "${p.title}" from saved.'),
                            action: SnackBarAction(
                              label: 'Undo',
                              textColor: AppColors.accentLime,
                              onPressed: () => _productService.toggleSaveProduct(p.id),
                            ),
                          ),
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

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Saved Products')),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: content),
      );
    }

    return content;
  }
}
