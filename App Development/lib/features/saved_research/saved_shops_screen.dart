import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../services/shop_service.dart';
import '../../shared/widgets/marketplace_badge.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../services/theme_service.dart';

class SavedShopsScreen extends StatefulWidget {
  final bool isStandalone;

  const SavedShopsScreen({super.key, this.isStandalone = false});

  @override
  State<SavedShopsScreen> createState() => _SavedShopsScreenState();
}

class _SavedShopsScreenState extends State<SavedShopsScreen> {
  final ShopService _shopService = ShopService();
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _shopService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _shopService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final savedShops = _shopService.savedShops.where((s) {
      if (_searchFilter.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          s.marketplace.toLowerCase().contains(_searchFilter.toLowerCase());
    }).toList();

    Widget content;
    if (_shopService.savedShops.isEmpty) {
      content = EmptyStateWidget(
        icon: Icons.storefront_outlined,
        title: 'No Saved Storefronts',
        message: 'Save interesting or competitor shops during your analysis runs to keep track of their growth and inventory updates.',
        actionText: 'Analyze E-Commerce Stores',
        onAction: () => Navigator.pushNamed(context, AppRoutes.shopScraper),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search within saved shops...',
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
            itemCount: savedShops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = savedShops[index];
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
                                '${s.country} • ${s.totalListings} listings • ${s.rating} ★',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.adaptiveSubtext,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Remove bookmark',
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          onPressed: () {
                            _shopService.toggleSaveShop(s.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed "${s.name}" from saved.'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: AppColors.accentLime,
                                  onPressed: () => _shopService.toggleSaveShop(s.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row 2: Solid Black Revenue + Marketplace Badge strictly inside main box
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '\$${s.monthlyRevenueEst.toInt()}/mo est. volume',
                          style: TextStyle(
                            color: ThemeService().isLight ? const Color(0xFF000000) : AppColors.primaryText,
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

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Saved Shops')),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: content),
      );
    }

    return content;
  }
}
