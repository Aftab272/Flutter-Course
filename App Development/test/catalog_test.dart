import 'package:flutter_test/flutter_test.dart';
import 'package:shop_scraper_app/data/marketplace_catalog_data.dart';

void main() {
  test('MarketplaceCatalogData generates exactly 1000 items per platform', () {
    final etsy = MarketplaceCatalogData.getEtsyProducts();
    final amz = MarketplaceCatalogData.getAmazonProducts();
    final ebay = MarketplaceCatalogData.getEbayProducts();
    final shopify = MarketplaceCatalogData.getShopifyProducts();
    final all = MarketplaceCatalogData.getAllProducts();

    expect(etsy.length, equals(1000));
    expect(amz.length, equals(1000));
    expect(ebay.length, equals(1000));
    expect(shopify.length, equals(1000));
    expect(all.length, equals(4000));

    expect(etsy.every((p) => p.marketplace == 'Etsy'), isTrue);
    expect(amz.every((p) => p.marketplace == 'Amazon'), isTrue);
    expect(ebay.every((p) => p.marketplace == 'eBay'), isTrue);
    expect(shopify.every((p) => p.marketplace == 'Shopify'), isTrue);

    // Verify IDs are unique
    final allIds = all.map((p) => p.id).toSet();
    expect(allIds.length, equals(4000));
  });
}

