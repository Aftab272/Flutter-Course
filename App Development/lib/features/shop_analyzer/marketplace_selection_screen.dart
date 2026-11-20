import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/marketplace_badge.dart';

class MarketplaceSelectionScreen extends StatelessWidget {
  const MarketplaceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    final marketplaces = [
      {
        'name': 'Etsy',
        'badge': 'Handmade & Vintage',
        'description': 'Analyze boutique artisan shops, printable digital downloads, print-on-demand listings, and trending craft tags.',
        'color': AppColors.etsyColor,
        'icon': Icons.brush_outlined,
        'activeCount': '14.2M Shops',
        'features': [
          'Digital download margin estimation',
          'Etsy Star Seller verification status',
          'Tag frequency & conversion analysis',
          'Print-on-demand SKU breakdown',
        ],
      },
      {
        'name': 'Amazon',
        'badge': 'FBA & Private Label',
        'description': 'Scrape Amazon storefronts, Prime-eligible listings, Buy Box competition, and estimated FBA monthly sales velocity.',
        'color': AppColors.amazonColor,
        'icon': Icons.local_shipping_outlined,
        'activeCount': '9.7M Sellers',
        'features': [
          'BSR (Best Sellers Rank) to unit conversion',
          'FBA fees & margin calculator simulation',
          'Review sentiment & video review velocity',
          'Sponsored keyword bidding intensity',
        ],
      },
      {
        'name': 'eBay',
        'badge': 'Refurbished & Collectibles',
        'description': 'Track liquid secondary market values, vintage consoles, authenticated streetwear, and auction sold-history trends.',
        'color': AppColors.ebayColor,
        'icon': Icons.sell_outlined,
        'activeCount': '18.1M Merchants',
        'features': [
          'Sold vs Active listing sell-through rate',
          'Authenticity Guarantee benchmark',
          'Refurbished electronics premium scoring',
          'Historical price floor analysis',
        ],
      },
      {
        'name': 'Shopify',
        'badge': 'Direct-To-Consumer (DTC)',
        'description': 'Inspect independent branded stores, viral TikTok and Pinterest apparel, theme technologies, and estimated order runs.',
        'color': AppColors.shopifyColor,
        'icon': Icons.shopping_bag_outlined,
        'activeCount': '4.8M Brands',
        'features': [
          'DTC average order value calculation',
          'Installed app & pixel stack detection',
          'Social viral velocity indicators',
          'Repeat purchase rate projections',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Marketplace Research Directory'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Target E-Commerce Marketplace',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a platform to filter intelligence, trigger automated scraping bots, or explore competitive research databases.',
              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = isDesktop ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: marketplaces.map((m) {
                    final color = m['color'] as Color;
                    final name = m['name'] as String;
                    final features = m['features'] as List<String>;

                    return SizedBox(
                      width: cardWidth,
                      child: CustomCard(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(m['icon'] as IconData, color: color, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: AppColors.adaptiveText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          m['badge'] as String,
                                          style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                MarketplaceBadge(marketplace: name),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              m['description'] as String,
                              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.borderColor),
                            const SizedBox(height: 14),
                            Text(
                              'SPECIALIZED ANALYTICS ENGINE',
                              style: TextStyle(
                                color: AppColors.adaptiveSubtext,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...features.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.accentLime),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Scrape $name',
                                    type: ButtonType.primary,
                                    icon: Icons.radar_rounded,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Products',
                                    type: ButtonType.secondary,
                                    icon: Icons.search_rounded,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    onPressed: () {
                                      ProductService().setMarketplace(name);
                                      Navigator.pop(context);
                                    },
                                  ),
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
        ),
      ),
    );
  }
}
