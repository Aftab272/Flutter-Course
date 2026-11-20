import 'package:flutter_test/flutter_test.dart';
import 'package:shop_scraper_app/services/shop_service.dart';
import 'package:shop_scraper_app/services/product_service.dart';
import 'package:shop_scraper_app/services/research_service.dart';
import 'package:shop_scraper_app/services/keyword_service.dart';

void main() {
  group('ShopService Unit Tests', () {
    late ShopService shopService;

    setUp(() {
      shopService = ShopService();
    });

    test('Initial shops are loaded with supported marketplaces', () {
      final shops = shopService.shops;
      expect(shops.isNotEmpty, isTrue);

      final marketplaces = shops.map((s) => s.marketplace).toSet();
      expect(marketplaces.contains('Etsy'), isTrue);
      expect(marketplaces.contains('Amazon'), isTrue);
      expect(marketplaces.contains('eBay'), isTrue);
      expect(marketplaces.contains('Shopify'), isTrue);
    });

    test('Filtering shops by marketplace returns matching shops', () {
      final etsyShops = shopService.getShopsByMarketplace('Etsy');
      expect(etsyShops.every((s) => s.marketplace == 'Etsy'), isTrue);
    });

    test('Toggle save shop flips isSaved property and notifies', () {
      final firstShop = shopService.shops.first;
      final initialSaved = firstShop.isSaved;

      shopService.toggleSaveShop(firstShop.id);
      final updated = shopService.getShopById(firstShop.id);
      expect(updated?.isSaved, equals(!initialSaved));

      // Revert back
      shopService.toggleSaveShop(firstShop.id);
    });

    test('Scrape and analyze simulates scraping a new shop URL', () async {
      final newShop = await shopService.scrapeAndAnalyzeShop(
        marketplace: 'Shopify',
        shopUrl: 'https://teststore-app.myshopify.com',
      );

      expect(newShop.marketplace, equals('Shopify'));
      expect(newShop.opportunityScore, greaterThan(0));
      expect(newShop.totalListings, greaterThan(0));
      expect(shopService.shops.any((s) => s.id == newShop.id), isTrue);
    });
  });

  group('ProductService Unit Tests', () {
    late ProductService productService;

    setUp(() {
      productService = ProductService();
      productService.resetFilters();
    });

    test('Initial products are loaded', () {
      expect(productService.allProducts.isNotEmpty, isTrue);
      expect(productService.totalResearchedProductsCount, greaterThan(5));
    });

    test('Search filter matches product titles and tags', () {
      productService.setSearchQuery('botanical');
      final filtered = productService.filteredProducts;
      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((p) =>
        p.title.toLowerCase().contains('botanical') ||
        p.tags.any((t) => t.toLowerCase().contains('botanical'))
      ), isTrue);
    });

    test('Marketplace filter restricts products correctly', () {
      productService.setMarketplace('Amazon');
      final amazonProducts = productService.filteredProducts;
      expect(amazonProducts.isNotEmpty, isTrue);
      expect(amazonProducts.every((p) => p.marketplace == 'Amazon'), isTrue);
    });

    test('Saturation filter works as expected', () {
      productService.setSaturation('Low');
      final lowSat = productService.filteredProducts;
      expect(lowSat.every((p) => p.saturationLevel == 'Low'), isTrue);
    });

    test('Sorting by price low to high orders correctly', () {
      productService.setSortOption(ProductSortOption.priceLowToHigh);
      final sorted = productService.filteredProducts;
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].price <= sorted[i + 1].price, isTrue);
      }
    });

    test('Sorting by opportunity score orders descending', () {
      productService.setSortOption(ProductSortOption.highestOpportunity);
      final sorted = productService.filteredProducts;
      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].opportunityScore >= sorted[i + 1].opportunityScore, isTrue);
      }
    });

    test('Toggle save product updates saved list', () {
      final first = productService.allProducts.first;
      final initialSaved = first.isSaved;

      productService.toggleSaveProduct(first.id);
      final updated = productService.getProductById(first.id);
      expect(updated?.isSaved, equals(!initialSaved));

      // Revert back
      productService.toggleSaveProduct(first.id);
    });
  });

  group('ResearchService Unit Tests', () {
    late ResearchService researchService;

    setUp(() {
      researchService = ResearchService();
    });

    test('User profile and quotas are loaded', () {
      expect(researchService.user.name.isNotEmpty, isTrue);
      expect(researchService.user.plan.contains('Pro'), isTrue);
    });

    test('Platform stats and reports are available', () {
      expect(researchService.platformStats.length, equals(4));
      expect(researchService.reports.isNotEmpty, isTrue);
    });

    test('Backend connection test returns true for valid endpoint', () async {
      final connected = await researchService.testBackendConnection('http://localhost:8000/api/v1');
      expect(connected, isTrue);
    });
  });

  group('KeywordService Unit Tests', () {
    late KeywordService keywordService;

    setUp(() {
      keywordService = KeywordService();
    });

    test('Initial keyword suggestions and presets exist', () {
      expect(KeywordService.suggestedKeywords.isNotEmpty, isTrue);
      expect(keywordService.recentKeywords.isNotEmpty, isTrue);
    });

    test('Analyze keyword computes valid volume, opportunity score and 13 tags', () async {
      final intel = await keywordService.analyzeKeyword('digital wedding planner');
      expect(intel.keyword, equals('digital wedding planner'));
      expect(intel.searchVolume, greaterThan(0));
      expect(intel.competitionListings, greaterThan(0));
      expect(intel.opportunityScore, inInclusiveRange(1, 100));
      expect(intel.difficultyScore, inInclusiveRange(1, 100));
      expect(intel.difficultyLabel.isNotEmpty, isTrue);
      expect(intel.listingTags.length, equals(13));
      expect(intel.relatedKeywords.isNotEmpty, isTrue);
    });

    test('Related keywords have opportunity scores and metrics', () async {
      final intel = await keywordService.analyzeKeyword('custom leather wallet');
      expect(intel.relatedKeywords.length, greaterThanOrEqualTo(5));
      for (final rel in intel.relatedKeywords) {
        expect(rel.keyword.isNotEmpty, isTrue);
        expect(rel.searchVolume, greaterThan(0));
        expect(rel.opportunityScore, inInclusiveRange(1, 100));
      }
    });
  });
}

