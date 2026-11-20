import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/demo_data.dart';
import '../models/product_model.dart';
import 'marketplace_api_client.dart';
import 'supabase_service.dart';

enum ProductSortOption {
  highestOpportunity,
  priceLowToHigh,
  priceHighToLow,
  mostReviews,
  newest,
}

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal() {
    _products = List.from(DemoData.initialProducts);
    _loadOfflineSavedIds();
    loadFromSupabase();
  }

  static const String _prefSavedProductsKey = 'offline_saved_product_ids';

  Future<void> _loadOfflineSavedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList(_prefSavedProductsKey);
      if (savedIds != null) {
        final savedSet = savedIds.toSet();
        for (int i = 0; i < _products.length; i++) {
          if (savedSet.contains(_products[i].id) && !_products[i].isSaved) {
            _products[i] = _products[i].copyWith(isSaved: true);
          }
        }
        _invalidateAndNotify();
      }
    } catch (_) {}
  }

  Future<void> _persistOfflineSavedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = _products.where((p) => p.isSaved).map((p) => p.id).toList();
      await prefs.setStringList(_prefSavedProductsKey, ids);
    } catch (_) {}
  }

  late List<ProductModel> _products;
  List<ProductModel>? _cachedFilteredProducts;

  void _invalidateAndNotify() {
    _cachedFilteredProducts = null;
    notifyListeners();
  }

  Future<void> loadFromSupabase() async {
    try {
      final fetched = await SupabaseService().fetchProducts();
      if (fetched.isNotEmpty && fetched.length >= _products.length) {
        _products = fetched;
        _invalidateAndNotify();
      }
    } catch (_) {}
  }
  String _searchQuery = '';
  String _selectedMarketplace = 'All Marketplaces';
  String _selectedCategory = 'All Categories';
  String _selectedSaturation = 'All';
  String _selectedProductType = 'All'; // 'All', 'Digital', 'Physical'
  ProductSortOption _sortOption = ProductSortOption.highestOpportunity;
  double _minPrice = 0.0;
  double _maxPrice = 300.0;

  List<ProductModel> get allProducts => List.unmodifiable(_products);
  List<ProductModel> get savedProducts => _products.where((p) => p.isSaved).toList();

  String get searchQuery => _searchQuery;
  String get selectedMarketplace => _selectedMarketplace;
  String get selectedCategory => _selectedCategory;
  String get selectedSaturation => _selectedSaturation;
  String get selectedProductType => _selectedProductType;
  ProductSortOption get sortOption => _sortOption;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  int get totalResearchedProductsCount => _products.length;
  int get totalSavedProductsCount => savedProducts.length;

  List<String> get availableCategories {
    final set = {'All Categories'};
    for (final p in _products) {
      set.add(p.category);
    }
    return set.toList();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _invalidateAndNotify();
    if (query.trim().length >= 2) {
      fetchLiveProducts(query: query.trim(), marketplace: _selectedMarketplace);
    }
  }

  bool _isLoadingLive = false;
  bool get isLoadingLive => _isLoadingLive;

  /// Fetches real live marketplace listings from the LootifyScrap backend API
  Future<void> fetchLiveProducts({required String query, String marketplace = 'All Marketplaces'}) async {
    _isLoadingLive = true;
    notifyListeners();
    try {
      final res = await MarketplaceApiClient().searchProducts(
        query: query,
        marketplace: marketplace,
        limit: 25,
      );
      if (res.reachable && res.products.isNotEmpty) {
        final existingIds = _products.map((p) => p.id).toSet();
        final fresh = res.products.where((p) => !existingIds.contains(p.id)).toList();
        if (fresh.isNotEmpty) {
          _products.insertAll(0, fresh);
          _cachedFilteredProducts = null;
        }
      }
    } catch (_) {}
    _isLoadingLive = false;
    notifyListeners();
  }

  void setMarketplace(String marketplace) {
    if (_selectedMarketplace == marketplace) return;
    _selectedMarketplace = marketplace;
    _invalidateAndNotify();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _invalidateAndNotify();
  }

  void setSaturation(String saturation) {
    if (_selectedSaturation == saturation) return;
    _selectedSaturation = saturation;
    _invalidateAndNotify();
  }

  void setSortOption(ProductSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _invalidateAndNotify();
  }

  void setPriceRange(double min, double max) {
    if (_minPrice == min && _maxPrice == max) return;
    _minPrice = min;
    _maxPrice = max;
    _invalidateAndNotify();
  }

  void setProductType(String type) {
    if (_selectedProductType == type) return;
    _selectedProductType = type;
    _invalidateAndNotify();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedMarketplace = 'All Marketplaces';
    _selectedCategory = 'All Categories';
    _selectedSaturation = 'All';
    _selectedProductType = 'All';
    _sortOption = ProductSortOption.highestOpportunity;
    _minPrice = 0.0;
    _maxPrice = 300.0;
    _invalidateAndNotify();
  }

  void toggleSaveProduct(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      final newSaved = !current.isSaved;
      _products[index] = current.copyWith(isSaved: newSaved);
      _invalidateAndNotify();

      // Persist locally for offline mode & sync with Supabase in background
      _persistOfflineSavedIds();
      SupabaseService().toggleSaveProduct(productId, newSaved);
    }
  }

  void addProducts(List<ProductModel> newProducts) {
    _products.insertAll(0, newProducts);
    _invalidateAndNotify();
    for (final p in newProducts) {
      SupabaseService().upsertProduct(p);
    }
  }

  void addProduct(ProductModel product) {
    final existingIndex = _products.indexWhere((p) => p.id == product.id);
    if (existingIndex != -1) {
      _products[existingIndex] = product;
    } else {
      _products.insert(0, product);
    }
    _invalidateAndNotify();
    SupabaseService().upsertProduct(product);
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> getProductsForShop(String shopId) {
    return _products.where((p) => p.shopId == shopId).toList();
  }

  List<ProductModel> getRelatedProducts(ProductModel product) {
    return _products
        .where((p) => p.id != product.id && (p.category == product.category || p.marketplace == product.marketplace))
        .take(4)
        .toList();
  }

  List<ProductModel> get filteredProducts {
    if (_cachedFilteredProducts != null) {
      return _cachedFilteredProducts!;
    }
    final query = _searchQuery.trim().toLowerCase();
    final hasQuery = query.isNotEmpty;
    final hasMarketplace = _selectedMarketplace != 'All Marketplaces' && _selectedMarketplace.isNotEmpty;
    final marketLower = _selectedMarketplace.toLowerCase();
    final hasCategory = _selectedCategory != 'All Categories' && _selectedCategory.isNotEmpty;
    final catLower = _selectedCategory.toLowerCase();
    final hasSaturation = _selectedSaturation != 'All' && _selectedSaturation.isNotEmpty;
    final satLower = _selectedSaturation.toLowerCase();

    List<ProductModel> list = _products.where((p) {
      // Price filter first (cheapest check)
      if (p.price < _minPrice || p.price > _maxPrice) {
        return false;
      }

      // Marketplace filter
      if (hasMarketplace && p.marketplace.toLowerCase() != marketLower) {
        return false;
      }

      // Saturation filter
      if (hasSaturation && p.saturationLevel.toLowerCase() != satLower) {
        return false;
      }

      // Category filter
      if (hasCategory && p.category.toLowerCase() != catLower) {
        return false;
      }

      // Search text match (title, category, tags, shopName, or any keyword word token)
      if (hasQuery) {
        final titleLower = p.title.toLowerCase();
        final shopLower = p.shopName.toLowerCase();
        final catLowerP = p.category.toLowerCase();
        final matchesExact = titleLower.contains(query) ||
            shopLower.contains(query) ||
            catLowerP.contains(query) ||
            p.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesExact) {
          final tokens = query.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
          final matchesAnyToken = tokens.isNotEmpty &&
              tokens.any((tok) =>
                  titleLower.contains(tok) ||
                  catLowerP.contains(tok) ||
                  shopLower.contains(tok) ||
                  p.tags.any((t) => t.toLowerCase().contains(tok)));
          if (!matchesAnyToken) {
            return false;
          }
        }
      }

      // Product Type filter (All, Digital, Physical)
      if (_selectedProductType == 'Digital') {
        final isDigital = p.tags.any((t) =>
                t.toLowerCase().contains('digital') ||
                t.toLowerCase().contains('printable') ||
                t.toLowerCase().contains('download') ||
                t.toLowerCase().contains('svg') ||
                t.toLowerCase().contains('template') ||
                t.toLowerCase().contains('pdf') ||
                t.toLowerCase().contains('planner')) ||
            p.category.toLowerCase().contains('digital') ||
            p.title.toLowerCase().contains('digital') ||
            p.title.toLowerCase().contains('planner') ||
            p.title.toLowerCase().contains('printable');
        if (!isDigital) return false;
      } else if (_selectedProductType == 'Physical') {
        final isDigital = p.tags.any((t) =>
                t.toLowerCase().contains('digital') ||
                t.toLowerCase().contains('printable') ||
                t.toLowerCase().contains('download') ||
                t.toLowerCase().contains('svg') ||
                t.toLowerCase().contains('template') ||
                t.toLowerCase().contains('pdf') ||
                t.toLowerCase().contains('planner')) ||
            p.category.toLowerCase().contains('digital') ||
            p.title.toLowerCase().contains('digital') ||
            p.title.toLowerCase().contains('planner') ||
            p.title.toLowerCase().contains('printable');
        if (isDigital) return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortOption) {
      case ProductSortOption.highestOpportunity:
        list.sort((a, b) => b.opportunityScore.compareTo(a.opportunityScore));
        break;
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.mostReviews:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case ProductSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // When user searches a keyword (e.g. "watch"), always rank direct title matches FIRST!
    if (hasQuery) {
      list.sort((a, b) {
        final aTitle = a.title.toLowerCase().contains(query) ? 1 : 0;
        final bTitle = b.title.toLowerCase().contains(query) ? 1 : 0;
        if (aTitle != bTitle) return bTitle.compareTo(aTitle);
        return 0;
      });
    }

    _cachedFilteredProducts = list;
    return list;
  }
}

