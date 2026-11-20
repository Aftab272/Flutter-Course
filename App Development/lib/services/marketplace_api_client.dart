import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/shop_model.dart';

/// Secure Frontend HTTP Client for LootifyScrap Backend API Gateway.
/// Never stores or sends secret marketplace API keys from Flutter code.
class MarketplaceApiClient {
  static final MarketplaceApiClient _instance = MarketplaceApiClient._internal();
  factory MarketplaceApiClient() => _instance;
  MarketplaceApiClient._internal();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  String _baseUrl = _defaultBaseUrl;
  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isNotEmpty) _baseUrl = trimmed;
  }

  Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch real live marketplace products from backend gateway
  Future<({List<ProductModel> products, List<Map<String, dynamic>> providerStatuses, bool reachable})> searchProducts({
    required String query,
    String marketplace = 'All Marketplaces',
    int page = 1,
    int limit = 20,
    double minPrice = 0,
    double maxPrice = 999999,
    String sort = 'relevance',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/search').replace(queryParameters: {
        'q': query,
        'marketplace': marketplace,
        'page': '$page',
        'limit': '$limit',
        'minPrice': '$minPrice',
        'maxPrice': '$maxPrice',
        'sort': sort,
      });

      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) {
        return (products: <ProductModel>[], providerStatuses: <Map<String, dynamic>>[], reachable: true);
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rawProducts = (data['products'] as List<dynamic>? ?? []);
      final statuses = (data['providerStatuses'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      final products = rawProducts.whereType<Map<String, dynamic>>().map(_mapProduct).toList();
      return (products: products, providerStatuses: statuses, reachable: true);
    } catch (e) {
      debugPrint('[MarketplaceApiClient] searchProducts offline/unreachable: $e');
      return (products: <ProductModel>[], providerStatuses: <Map<String, dynamic>>[], reachable: false);
    }
  }

  /// Fetch real live keyword intelligence from backend gateway
  Future<Map<String, dynamic>?> researchKeyword({
    required String query,
    String marketplace = 'All Marketplaces',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/keywords/research').replace(queryParameters: {
        'q': query,
        'marketplace': marketplace,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[MarketplaceApiClient] researchKeyword offline/unreachable: $e');
    }
    return null;
  }

  /// Fetch real live shop details & products from backend gateway
  Future<({ShopModel? shop, List<ProductModel> products, String? status, String? error, bool reachable})> analyzeShop({
    required String url,
    String marketplace = '',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/shops/analyze').replace(queryParameters: {
        'url': url,
        if (marketplace.isNotEmpty) 'marketplace': marketplace,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200) {
        return (
          shop: null,
          products: <ProductModel>[],
          status: 'error',
          error: (data['error'] ?? 'Shop lookup failed').toString(),
          reachable: true,
        );
      }

      final status = data['status']?.toString();
      final error = data['error']?.toString();
      final rawShop = data['shop'] as Map<String, dynamic>?;
      final rawProducts = (data['products'] as List<dynamic>? ?? []);
      final products = rawProducts.whereType<Map<String, dynamic>>().map(_mapProduct).toList();

      ShopModel? shop;
      if (rawShop != null) {
        shop = ShopModel(
          id: (rawShop['id'] ?? 'live_shop_${DateTime.now().millisecondsSinceEpoch}').toString(),
          name: (rawShop['name'] ?? 'Live Store').toString(),
          marketplace: (rawShop['marketplace'] ?? marketplace).toString(),
          url: (rawShop['url'] ?? url).toString(),
          logoUrl: (rawShop['logoUrl'] ?? '').toString(),
          ownerName: (rawShop['ownerName'] ?? 'Verified Merchant').toString(),
          ownerAvatarUrl: '',
          rating: (rawShop['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: (rawShop['reviewCount'] as num?)?.toInt() ?? 0,
          totalListings: (rawShop['totalListings'] as num?)?.toInt() ?? products.length,
          totalSales: (rawShop['totalSales'] as num?)?.toInt() ?? 0,
          monthlyRevenueEst: (rawShop['monthlyRevenueEst'] as num?)?.toDouble() ?? 0.0,
          avgPrice: (rawShop['avgPrice'] as num?)?.toDouble() ?? 0.0,
          country: (rawShop['country'] ?? 'Global').toString(),
          openYear: (rawShop['openYear'] as num?)?.toInt() ?? DateTime.now().year,
          opportunityScore: products.isNotEmpty ? 85 : 0,
          description: (rawShop['description'] ?? '').toString(),
          topCategories: products.map((p) => p.category).toSet().take(3).toList(),
          topTags: products.expand((p) => p.tags).toSet().take(8).toList(),
          badges: const ['Live Verified Store'],
        );
      }

      return (shop: shop, products: products, status: status, error: error, reachable: true);
    } catch (e) {
      debugPrint('[MarketplaceApiClient] analyzeShop offline/unreachable: $e');
      return (shop: null, products: <ProductModel>[], status: 'offline', error: null, reachable: false);
    }
  }

  ProductModel _mapProduct(Map<String, dynamic> raw) {
    final price = (raw['price'] as num?)?.toDouble() ?? 0.0;
    final origPrice = (raw['originalPrice'] as num?)?.toDouble();
    final images = (raw['imageUrls'] as List<dynamic>? ?? []).map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    final tags = (raw['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).where((s) => s.isNotEmpty).toList();

    return ProductModel(
      id: (raw['id'] ?? 'live_${DateTime.now().millisecondsSinceEpoch}').toString(),
      shopId: (raw['shopId'] ?? 'live_shop').toString(),
      shopName: (raw['shopName'] ?? raw['brand'] ?? 'Live Store').toString(),
      marketplace: (raw['marketplace'] ?? 'Shopify').toString(),
      title: (raw['title'] ?? 'Live Marketplace Product').toString(),
      price: price,
      originalPrice: origPrice,
      rating: (raw['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (raw['reviewCount'] as num?)?.toInt() ?? 0,
      salesEstimate: 0,
      monthlyRevenue: 0.0,
      opportunityScore: 82,
      saturationLevel: 'Live',
      competitionScore: 2.5,
      category: (raw['category'] ?? 'Marketplace').toString(),
      tags: tags.isNotEmpty ? tags : ['live'],
      description: (raw['description'] ?? '').toString(),
      imageUrls: images,
      stockStatus: (raw['stockStatus'] ?? 'In Stock').toString(),
      createdAt: DateTime.tryParse((raw['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
