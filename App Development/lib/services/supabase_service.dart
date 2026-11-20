import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../data/demo_data.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';

class SupabaseService extends ChangeNotifier {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String _prefUrlKey = 'supabase_project_url';
  static const String _prefAnonKey = 'supabase_anon_key';

  String _currentUrl = SupabaseConfig.defaultUrl;
  String _currentAnonKey = SupabaseConfig.defaultAnonKey;
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _lastError;

  String get currentUrl => _currentUrl;
  String get currentAnonKey => _currentAnonKey;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase with persisted or default configuration
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUrl = prefs.getString(_prefUrlKey);
      final storedKey = prefs.getString(_prefAnonKey);

      // If no stored credentials or previous dummy project, use the active Supabase project
      if (storedUrl == null ||
          storedUrl.contains('zrhdkmvxyxvwolqfbgap') ||
          storedUrl.contains('demo-shop-scraper')) {
        _currentUrl = SupabaseConfig.defaultUrl;
        _currentAnonKey = SupabaseConfig.defaultAnonKey;
        await prefs.setString(_prefUrlKey, _currentUrl);
        await prefs.setString(_prefAnonKey, _currentAnonKey);
      } else {
        _currentUrl = storedUrl;
        _currentAnonKey = storedKey ?? SupabaseConfig.defaultAnonKey;
      }

      if (_isValidUrl(_currentUrl) && _currentAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: _currentUrl,
          anonKey: _currentAnonKey,
          debug: kDebugMode,
        ).timeout(const Duration(seconds: 2));
        _isInitialized = true;
        _isConnected = true;
        _lastError = null;
      }
    } catch (e) {
      _isConnected = false;
      _lastError = 'Offline Mode (Local Cache Active)';
      debugPrint('[SupabaseService] Offline or init error: $e');
    }
    notifyListeners();
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
  }

  /// Update credentials from Settings and test connection
  Future<bool> updateCredentials({
    required String url,
    required String anonKey,
  }) async {
    final cleanUrl = url.trim();
    final cleanKey = anonKey.trim();

    if (!_isValidUrl(cleanUrl)) {
      _lastError = 'Invalid Supabase URL format. It must start with https://';
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUrlKey, cleanUrl);
      await prefs.setString(_prefAnonKey, cleanKey);

      _currentUrl = cleanUrl;
      _currentAnonKey = cleanKey;

      // Re-initialize client if possible
      try {
        await Supabase.initialize(
          url: cleanUrl,
          anonKey: cleanKey,
        );
        _isInitialized = true;
      } catch (_) {
        // If already initialized, disposing/re-init in Supabase is handled via new requests
        _isInitialized = true;
      }

      final pingSuccess = await pingConnection();
      _isConnected = pingSuccess;
      _lastError = pingSuccess ? null : 'Could not query Supabase tables. Check your URL & Key.';
      notifyListeners();
      return pingSuccess;
    } catch (e) {
      _lastError = e.toString();
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Test Supabase live connectivity
  Future<bool> pingConnection() async {
    final c = client;
    if (c == null) {
      _isConnected = false;
      return false;
    }

    try {
      // Try querying the shops table or auth health check
      await c.from(SupabaseConfig.tableShops).select('id').limit(1);
      _isConnected = true;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Ping check result: $e');
      // If table does not exist or credentials rejected:
      _isConnected = false;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // SUPABASE AUTHENTICATION
  // ==========================================

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final c = client;
    if (c == null) {
      throw Exception('Supabase is not initialized. Please configure credentials in Settings.');
    }
    final response = await c.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    notifyListeners();
    return response;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final c = client;
    if (c == null) {
      throw Exception('Supabase is not initialized. Please configure credentials in Settings.');
    }
    final response = await c.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    notifyListeners();
    return response;
  }

  Future<bool> isGoogleProviderEnabled() async {
    try {
      final url = Uri.parse('$_currentUrl/auth/v1/authorize?provider=google');
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 400 && res.body.contains('provider is not enabled')) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    final c = client;
    if (c == null) {
      throw Exception('Supabase client is not initialized.');
    }
    final isEnabled = await isGoogleProviderEnabled();
    if (!isEnabled) {
      throw Exception('Unsupported provider: provider is not enabled in Supabase Console.');
    }
    try {
      final success = await c.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.shopscraper://login-callback',
      );
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[SupabaseService] Google OAuth: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    final c = client;
    if (c != null) {
      await c.auth.signOut();
      notifyListeners();
    }
  }

  // ==========================================
  // SHOPS REPOSITORY (CRUD)
  // ==========================================

  Future<List<ShopModel>> fetchShops() async {
    final c = client;
    if (c == null) return DemoData.initialShops;

    try {
      final List<dynamic> response = await c
          .from(SupabaseConfig.tableShops)
          .select()
          .order('monthly_revenue_est', ascending: false);

      if (response.isEmpty) {
        return DemoData.initialShops;
      }

      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ShopModel(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          marketplace: map['marketplace']?.toString() ?? 'Etsy',
          url: map['url']?.toString() ?? '',
          logoUrl: map['logo_url']?.toString() ?? '',
          rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
          reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
          totalSales: (map['total_sales'] as num?)?.toInt() ?? 0,
          monthlyRevenueEst: (map['monthly_revenue_est'] as num?)?.toDouble() ?? 0.0,
          country: map['country']?.toString() ?? 'United States',
          openYear: (map['open_year'] as num?)?.toInt() ?? 2021,
          totalListings: (map['total_listings'] as num?)?.toInt() ?? 0,
          avgPrice: (map['avg_price'] as num?)?.toDouble() ?? 0.0,
          topCategories: List<String>.from(map['top_categories'] ?? []),
          topTags: List<String>.from(map['top_tags'] ?? []),
          badges: List<String>.from(map['badges'] ?? []),
          isSaved: map['is_saved'] as bool? ?? false,
          opportunityScore: (map['opportunity_score'] as num?)?.toInt() ?? 75,
          description: map['description']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchShops fallback to local: $e');
      return DemoData.initialShops;
    }
  }

  Future<void> upsertShop(ShopModel shop) async {
    final c = client;
    if (c == null) return;

    try {
      await c.from(SupabaseConfig.tableShops).upsert({
        'id': shop.id,
        'name': shop.name,
        'marketplace': shop.marketplace,
        'url': shop.url,
        'logo_url': shop.logoUrl,
        'rating': shop.rating,
        'review_count': shop.reviewCount,
        'total_sales': shop.totalSales,
        'monthly_revenue_est': shop.monthlyRevenueEst,
        'country': shop.country,
        'open_year': shop.openYear,
        'total_listings': shop.totalListings,
        'avg_price': shop.avgPrice,
        'top_categories': shop.topCategories,
        'top_tags': shop.topTags,
        'badges': shop.badges,
        'is_saved': shop.isSaved,
        'opportunity_score': shop.opportunityScore,
        'description': shop.description,
      });
    } catch (e) {
      debugPrint('[SupabaseService] upsertShop error: $e');
    }
  }

  Future<void> toggleSaveShop(String shopId, bool isSaved) async {
    final c = client;
    if (c == null) return;

    try {
      await c
          .from(SupabaseConfig.tableShops)
          .update({'is_saved': isSaved})
          .eq('id', shopId);
    } catch (e) {
      debugPrint('[SupabaseService] toggleSaveShop error: $e');
    }
  }

  // ==========================================
  // PRODUCTS REPOSITORY (CRUD)
  // ==========================================

  Future<List<ProductModel>> fetchProducts() async {
    final c = client;
    if (c == null) return DemoData.initialProducts;

    try {
      final List<dynamic> response = await c
          .from(SupabaseConfig.tableProducts)
          .select()
          .order('opportunity_score', ascending: false);

      if (response.isEmpty) {
        return DemoData.initialProducts;
      }

      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ProductModel(
          id: map['id']?.toString() ?? '',
          shopId: map['shop_id']?.toString() ?? '',
          shopName: map['shop_name']?.toString() ?? '',
          marketplace: map['marketplace']?.toString() ?? 'Etsy',
          title: map['title']?.toString() ?? '',
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
          originalPrice: (map['original_price'] as num?)?.toDouble(),
          currency: map['currency']?.toString() ?? '\$',
          rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
          reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
          salesEstimate: (map['sales_estimate'] as num?)?.toInt() ?? 0,
          monthlyRevenue: (map['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
          opportunityScore: (map['opportunity_score'] as num?)?.toInt() ?? 80,
          saturationLevel: map['saturation_level']?.toString() ?? 'Medium',
          competitionScore: (map['competition_score'] as num?)?.toDouble() ?? 2.5,
          category: map['category']?.toString() ?? 'General',
          tags: List<String>.from(map['tags'] ?? []),
          description: map['description']?.toString() ?? '',
          imageUrls: List<String>.from(map['image_urls'] ?? []),
          stockStatus: map['stock_status']?.toString() ?? 'In Stock',
          isSaved: map['is_saved'] as bool? ?? false,
          createdAt: map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchProducts fallback: $e');
      return DemoData.initialProducts;
    }
  }

  Future<void> upsertProduct(ProductModel product) async {
    final c = client;
    if (c == null) return;

    try {
      await c.from(SupabaseConfig.tableProducts).upsert({
        'id': product.id,
        'shop_id': product.shopId,
        'shop_name': product.shopName,
        'marketplace': product.marketplace,
        'title': product.title,
        'price': product.price,
        'original_price': product.originalPrice,
        'currency': product.currency,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'sales_estimate': product.salesEstimate,
        'monthly_revenue': product.monthlyRevenue,
        'opportunity_score': product.opportunityScore,
        'saturation_level': product.saturationLevel,
        'competition_score': product.competitionScore,
        'category': product.category,
        'tags': product.tags,
        'description': product.description,
        'image_urls': product.imageUrls,
        'stock_status': product.stockStatus,
        'is_saved': product.isSaved,
      });
    } catch (e) {
      debugPrint('[SupabaseService] upsertProduct error: $e');
    }
  }

  Future<void> toggleSaveProduct(String productId, bool isSaved) async {
    final c = client;
    if (c == null) return;

    try {
      await c
          .from(SupabaseConfig.tableProducts)
          .update({'is_saved': isSaved})
          .eq('id', productId);
    } catch (e) {
      debugPrint('[SupabaseService] toggleSaveProduct error: $e');
    }
  }

  // ==========================================
  // SEED INITIAL DATA TO SUPABASE
  // ==========================================

  Future<int> seedDemoDataToSupabase() async {
    final c = client;
    if (c == null) {
      throw Exception('Supabase client is not connected. Configure your URL & Key in Settings.');
    }

    int count = 0;
    // Seed shops
    for (final shop in DemoData.initialShops) {
      await upsertShop(shop);
      count++;
    }
    // Seed products
    for (final product in DemoData.initialProducts) {
      await upsertProduct(product);
      count++;
    }

    return count;
  }
}
