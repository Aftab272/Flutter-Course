import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/product_service.dart';
import '../../services/shop_service.dart';
import 'saved_products_screen.dart';
import 'saved_shops_screen.dart';

class SavedResearchTabScreen extends StatefulWidget {
  const SavedResearchTabScreen({super.key});

  @override
  State<SavedResearchTabScreen> createState() => _SavedResearchTabScreenState();
}

class _SavedResearchTabScreenState extends State<SavedResearchTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _productService.addListener(_onUpdate);
    _shopService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productService.removeListener(_onUpdate);
    _shopService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final savedProductsCount = _productService.savedProducts.length;
    final savedShopsCount = _shopService.savedShops.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Research & Watchlists',
              style: TextStyle(
                color: AppColors.adaptiveText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize your bookmarked products and analyzed storefronts in one central hub.',
              style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Tab Buttons (Blue active indicator with crisp spacing & zero clipping)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.adaptiveSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.22)),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicator: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.adaptiveText,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Saved Products ($savedProductsCount)', maxLines: 1),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Saved Shops ($savedShopsCount)', maxLines: 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SingleChildScrollView(child: SavedProductsScreen()),
                  SingleChildScrollView(child: SavedShopsScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

