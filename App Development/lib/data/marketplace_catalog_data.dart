import '../models/product_model.dart';

class MarketplaceCatalogData {
  static List<ProductModel>? _cachedAll;
  static List<ProductModel>? _cachedEtsy;
  static List<ProductModel>? _cachedAmazon;
  static List<ProductModel>? _cachedEbay;
  static List<ProductModel>? _cachedShopify;

  static List<ProductModel> getAllProducts() {
    if (_cachedAll != null) return _cachedAll!;
    final list = <ProductModel>[];
    list.addAll(getEtsyProducts());
    list.addAll(getAmazonProducts());
    list.addAll(getEbayProducts());
    list.addAll(getShopifyProducts());
    _cachedAll = List.unmodifiable(list);
    return _cachedAll!;
  }

  static List<ProductModel> getEtsyProducts() {
    if (_cachedEtsy != null) return _cachedEtsy!;
    final list = _generateEtsy();
    _cachedEtsy = List.unmodifiable(list);
    return _cachedEtsy!;
  }

  static List<ProductModel> getAmazonProducts() {
    if (_cachedAmazon != null) return _cachedAmazon!;
    final list = _generateAmazon();
    _cachedAmazon = List.unmodifiable(list);
    return _cachedAmazon!;
  }

  static List<ProductModel> getEbayProducts() {
    if (_cachedEbay != null) return _cachedEbay!;
    final list = _generateEbay();
    _cachedEbay = List.unmodifiable(list);
    return _cachedEbay!;
  }

  static List<ProductModel> getShopifyProducts() {
    if (_cachedShopify != null) return _cachedShopify!;
    final list = _generateShopify();
    _cachedShopify = List.unmodifiable(list);
    return _cachedShopify!;
  }

  // =========================================================================
  // ETSY CATALOG GENERATOR (1,000 AUTHENTIC PRODUCTS)
  // =========================================================================
  static List<ProductModel> _generateEtsy() {
    const archetypes = [
      _Archetype(
        baseTitle: 'Custom Birth Flower Name Necklace',
        category: 'Jewelry & Accessories',
        basePrice: 24.50,
        tags: ['birth flower necklace', 'personalized jewelry', 'initial pendant', 'handmade gift for her', 'floral necklace'],
        description: 'Delicately engraved disc necklace crafted with botanical birth month blooms and custom script name. Hypoallergenic and tarnish-resistant for daily wear.',
        images: [
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600',
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Chunky Merino Wool Hand-Knit Throw Blanket',
        category: 'Home & Living',
        basePrice: 85.00,
        tags: ['chunky knit blanket', 'merino wool throw', 'boho home decor', 'cozy arm knit', 'hygge bedroom'],
        description: 'Super-soft 100% natural pure merino wool yarn hand-knitted into a cloud-soft chunky texture. Breathable, hypoallergenic, and luxurious accent piece.',
        images: [
          'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600',
          'https://images.unsplash.com/photo-1554995207-c18c20360250?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Personalized Full-Grain Leather Passport Cover & Tag',
        category: 'Bags & Purses',
        basePrice: 34.00,
        tags: ['leather passport holder', 'personalized travel wallet', 'groomsmen gift', 'luggage tag set', 'horween leather'],
        description: 'Handcrafted from vegetable-tanned full-grain leather that develops a rich natural patina over time. Custom debossed initials with brass hardware.',
        images: [
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600',
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Solid Oak Rustic Floating Wall Shelf',
        category: 'Home & Living',
        basePrice: 48.00,
        tags: ['floating shelf', 'solid oak woodwork', 'rustic farmhouse', 'concealed bracket', 'bathroom plant shelf'],
        description: 'Sustainably harvested solid white oak finished with non-toxic matte hardwax oil. Includes heavy-duty concealed steel floating mounting brackets.',
        images: [
          'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600',
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Aromatherapy Soy Wax Scented Candle in Amber Jar',
        category: 'Home & Living',
        basePrice: 19.50,
        tags: ['soy candle', 'amber glass jar', 'aromatherapy home', 'clean burn wooden wick', 'non toxic candle'],
        description: 'Hand-poured 100% domestic soy wax with crackling wood wick and phthalate-free botanical essential oils. 50+ hours clean soot-free burn time.',
        images: [
          'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=600',
          'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Custom Watercolor Pet Portrait Hand-Painted Painting',
        category: 'Art & Collectibles',
        basePrice: 52.00,
        tags: ['pet portrait watercolor', 'custom dog art', 'cat painting memory', 'personalized pet gift', 'archival watercolor'],
        description: 'Commissioned original watercolor portrait created from your pet photograph. Rendered on 300gsm cold press cotton paper with archival pigments.',
        images: [
          'https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=600',
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Boho Macrame Geometric Wall Hanging Tapestry',
        category: 'Home & Living',
        basePrice: 38.00,
        tags: ['macrame wall hanging', 'boho nursery decor', 'handwoven tapestry', 'recycled cotton cord', 'scandi decor'],
        description: 'Intricately hand-knotted from 100% unbleached natural cotton rope onto a natural smoothed birch wood branch. Adds warmth and organic texture.',
        images: [
          'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?w=600',
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Hand-Embroidered Wildflower Canvas Tote Bag',
        category: 'Bags & Purses',
        basePrice: 26.00,
        tags: ['embroidered tote bag', 'botanical grocery bag', 'cottagecore canvas', 'aesthetic shopping bag', 'reusable tote'],
        description: 'Durable 14oz heavy cotton duck canvas stitched with delicate botanical wildflower blossoms. Reinforced box stitching at stress points with inner pocket.',
        images: [
          'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600',
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Raw Natural Amethyst Geode Crystal Specimen',
        category: 'Art & Collectibles',
        basePrice: 32.00,
        tags: ['amethyst geode cluster', 'raw healing crystal', 'mineral specimen', 'boho altar decor', 'meditation stone'],
        description: 'Ethically sourced deep purple Uruguayan amethyst cluster with natural basalt matrix. Untreated natural points showcasing stunning crystalline sparkle.',
        images: [
          'https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?w=600',
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Minimalist 14k Solid Gold Huggie Hoop Earrings',
        category: 'Jewelry & Accessories',
        basePrice: 28.00,
        tags: ['gold huggie hoops', 'minimalist earrings', 'cartilage piercing', '14k gold vermeil', 'hypoallergenic sleep earrings'],
        description: 'Ultra-comfortable clicker closure huggies in genuine 14k gold over solid 925 sterling silver. Water-resistant, nickel-free, and designed for 24/7 wear.',
        images: [
          'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=600',
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Concrete Geometric Succulent Planter Pot',
        category: 'Home & Living',
        basePrice: 22.00,
        tags: ['concrete planter', 'succulent pot with drainage', 'geometric desk decor', 'industrial modern', 'indoor garden'],
        description: 'Hand-cast architectural concrete pot with built-in drainage hole and silicone feet pads. Sealed with water-repellent eco beeswax.',
        images: [
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600',
          'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Personalized Engraved Walnut Wood Cutting Board',
        category: 'Weddings & Celebrations',
        basePrice: 45.00,
        tags: ['engraved cutting board', 'wedding anniversary gift', 'walnut charcuterie', 'custom family name board', 'kitchen keepsake'],
        description: 'Solid premium black walnut edge-grain board treated with food-grade organic mineral oil. Custom laser engraved with family crest or names.',
        images: [
          'https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?w=600',
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vintage Handwoven Turkish Kilim Wool Rug',
        category: 'Home & Living',
        basePrice: 140.00,
        tags: ['turkish kilim rug', 'vintage handwoven runner', 'anatolia geometric wool', 'boho entryway rug', 'organic vegetable dye'],
        description: 'Authentic Anatolian flat-weave wool runner with traditional tribal symbology. Washed and naturally sun-cured with vegetable-dyed earthy yarn.',
        images: [
          'https://images.unsplash.com/photo-1600121848594-d8644e57abab?w=600',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Handmade Ceramic Matcha Tea Bowl with Chasen Whisk',
        category: 'Kitchen & Dining',
        basePrice: 42.00,
        tags: ['matcha bowl chawan', 'hand thrown pottery', 'bamboo whisk set', 'japanese tea ceremony', 'wabi sabi ceramic'],
        description: 'Stoneware chawan bowl wheel-thrown with spout indentation and glazed in reactive satin matte. Includes 100-prong bamboo chasen and scoop.',
        images: [
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=600',
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Japanese Linen Cross-Back Cooking Apron',
        category: 'Clothing & Shoes',
        basePrice: 36.00,
        tags: ['linen apron', 'cross back pinafore', 'japanese workwear', 'baking apron with pockets', 'pure french flax'],
        description: 'Stonewashed 100% French flax linen pinafore with no neck tie straps. Ergonomic crossover back distributes weight evenly for cooking and gardening.',
        images: [
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
          'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Custom LED Neon Sign for Wall Decor & Events',
        category: 'Home & Living',
        basePrice: 95.00,
        tags: ['custom neon sign', 'led name light', 'wedding backdrop light', 'bedroom aesthetic neon', 'acrylic neon wall art'],
        description: 'Handcrafted flexible silicon LED neon tubes mounted on transparent laser-cut acrylic backboard. Includes wireless remote with 10 dimmer steps.',
        images: [
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600',
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Hand-Forged Damascus Steel Japanese Santoku Knife',
        category: 'Kitchen & Dining',
        basePrice: 88.00,
        tags: ['damascus chef knife', 'japanese santoku', 'kitchen cutlery', 'rosewood handle', 'hand forged blade'],
        description: '67-layer Damascus steel blade with VG-10 cutting core heat treated to 60±2 HRC. Ergonomic octagonal natural rosewood handle with brass spacer.',
        images: [
          'https://images.unsplash.com/photo-1593618998160-e34014e67546?w=600',
          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Handmade Speckled Ceramic Coffee Mug with Thumb Rest',
        category: 'Kitchen & Dining',
        basePrice: 29.00,
        tags: ['pottery coffee mug', 'speckled clay cup', 'hand thrown artisan ceramic', 'thumb rest mug', 'cozy morning mug'],
        description: '14oz wheel-thrown stoneware mug with ergonomic pulled handle and custom thumb contour. Glazed in toasted marshmallow with raw iron speckles.',
        images: [
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
          'https://images.unsplash.com/photo-1577937927133-66ef06acdf18?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Dried Floral Pampas Grass Boho Centerpiece Bouquet',
        category: 'Weddings & Celebrations',
        basePrice: 35.00,
        tags: ['pampas grass bouquet', 'dried flower arrangement', 'boho wedding centerpiece', 'bunny tails palm spear', 'forever flowers'],
        description: 'Naturally preserved fluffy pampas plumes, sun palms, bunny tails, and baby breath florals. Lasts 3+ years with zero watering needed.',
        images: [
          'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=600',
          'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Personalized Night Sky Celestial Star Map Canvas',
        category: 'Paper & Party Supplies',
        basePrice: 38.00,
        tags: ['star map canvas', 'constellation night sky', 'anniversary date print', 'custom coordinates gift', 'framed star chart'],
        description: 'Mathematically generated astronomical star chart calculated to your exact milestone date and location. Printed on 100% cotton museum canvas.',
        images: [
          'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Handmade Wooden Chess Set with Weighted Pieces',
        category: 'Art & Collectibles',
        basePrice: 110.00,
        tags: ['wooden chess set', 'carved chess board', 'staunton chessmen', 'woodworking board game', 'luxury desk game'],
        description: 'Hand-carved Staunton design pieces crafted from sheesham and boxwood with brass weighted bottoms. Folding board with green felt velvet storage.',
        images: [
          'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=600',
          'https://images.unsplash.com/photo-1586165368502-1bad197a6461?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Custom Leather Journal Notebook with Deckle Edge Paper',
        category: 'Craft Supplies & Tools',
        basePrice: 33.00,
        tags: ['leather journal', 'deckle edge cotton paper', 'grimoire sketchbook', 'hand bound diary', 'vintage calligraphy book'],
        description: 'Hand-bound buffalo leather notebook filled with 240 pages of tree-free recycled deckle cotton paper. Fountain pen friendly with leather wrap tie.',
        images: [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Botanical Herbarium Framed Pressed Flower Wall Art',
        category: 'Art & Collectibles',
        basePrice: 42.00,
        tags: ['pressed flower frame', 'floating glass herbarium', 'real botanical specimen', 'brass framed flora', 'cottagecore wall art'],
        description: 'Authentic pressed meadow wildflowers preserved between double pane float glass encased in antique soldered brass. Includes brass hanging chain.',
        images: [
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Handmade Beeswax Reusable Food Wrap Eco Pack',
        category: 'Home & Living',
        basePrice: 16.00,
        tags: ['beeswax food wrap', 'zero waste kitchen', 'organic cotton wrap', 'plastic free storage', 'sustainable food covers'],
        description: 'Organic GOTS cotton fabric infused with raw local beeswax, jojoba oil, and tree resin. Natural antibacterial seal activated with warmth of hands.',
        images: [
          'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=600',
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Personalized Family Name Wooden Welcome Door Sign',
        category: 'Home & Living',
        basePrice: 39.00,
        tags: ['front door sign', 'wooden welcome hanger', 'family last name round', 'farmhouse porch decor', 'laser cut wood circle'],
        description: '18-inch birch wood round coated in weather-resistant polyurethane. 3D laser-cut raised lettering styled with greenery foliage and burlap bow.',
        images: [
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
          'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600',
        ],
      ),
    ];

    final modifiers = [
      'Personalized Initial Engraving',
      'Solid 14k Gold Finish',
      'Rose Gold Edition',
      'Sterling Silver 925',
      'Terracotta & Natural Cream',
      'Forest Green & Earthy Sage',
      'Artisan Small-Batch Handmade',
      'Vintage Distressed Finish',
      'Minimalist Nordic Edition',
      'Japandi Stoneware Edition',
      'Custom Monogrammed Gift Box',
      'Deluxe Double-Layered Pack',
      'Oversized Large Statement Size',
      'Petite Everyday Classic',
      'Boho Celestial Moon & Star Detail',
      'Raw Natural Organic Finish',
      'Hand-Burnished Wax Polish',
      'Lavender & Vanilla Scented',
      'Sandalwood & Smoked Amber',
      'Wild Sage & Sea Salt',
      'Dark Walnut Stain',
      'Natural Light Maple Wood',
      'French Flax Stonewashed Linen',
      'Gilded Edge 24k Accent',
      'Matte Charcoal Glaze',
      'Speckled Oatmeal Ceramic',
      'Bridal Wedding Keepsake Edition',
      'Baby Shower Keepsake Edition',
      'New Homeowner Housewarming Gift',
      'Holiday Festive Edition',
      'Limited Anniversary Release',
      'Organic Unbleached Cotton',
      'Heavy-Duty Saddle Stitched',
      'Double-Wick 16oz Jar',
      'Mini 3-Piece Sampler Set',
      'Heirloom Grade Handcrafted',
      'Contemporary Geometric Cut',
      'Eucalyptus & Mint Infusion',
      'Warm Honey Brass Finish',
      'Autumn Pumpkin & Clove Edition',
    ];

    final shops = [
      {'id': 'shop_etsy_01', 'name': 'BohoAestheticStudio'},
      {'id': 'shop_etsy_02', 'name': 'LeatherCraftsmanCo'},
      {'id': 'shop_etsy_03', 'name': 'VelvetPetalCreations'},
      {'id': 'shop_etsy_04', 'name': 'ArtisanClayWorks'},
      {'id': 'shop_etsy_05', 'name': 'TimberAndGrainStudio'},
      {'id': 'shop_etsy_06', 'name': 'GoldenHourMetals'},
      {'id': 'shop_etsy_07', 'name': 'LoomAndThreadShop'},
      {'id': 'shop_etsy_08', 'name': 'StarlightGemsAtelier'},
      {'id': 'shop_etsy_09', 'name': 'NordicPrintHaven'},
      {'id': 'shop_etsy_10', 'name': 'WildflowerEmporium'},
    ];

    final products = <ProductModel>[];
    int count = 0;

    for (int a = 0; a < archetypes.length; a++) {
      final arch = archetypes[a];
      for (int m = 0; m < modifiers.length; m++) {
        count++;
        final mod = modifiers[m];
        final id = 'etsy_${count.toString().padLeft(4, '0')}';
        final shop = shops[(a + m) % shops.length];
        final priceDelta = ((m % 5) - 2) * 3.5;
        final price = (arch.basePrice + priceDelta).clamp(12.50, 195.00);
        final origPrice = (price * 1.25).roundToDouble();
        final oppScore = 70 + ((a * 7 + m * 3) % 28);
        final satLevel = oppScore >= 88 ? 'Low' : (oppScore >= 78 ? 'Medium' : 'High');
        final rating = (4.70 + ((a + m) % 30) * 0.01).clamp(4.65, 5.00);
        final reviews = 45 + ((a * 100 + m * 37) % 3400);
        final sales = 110 + ((a * 150 + m * 53) % 5200);
        final revenue = (price * sales * 0.32).roundToDouble();

        products.add(
          ProductModel(
            id: id,
            shopId: shop['id']!,
            shopName: shop['name']!,
            marketplace: 'Etsy',
            title: '${arch.baseTitle} - $mod',
            price: double.parse(price.toStringAsFixed(2)),
            originalPrice: double.parse(origPrice.toStringAsFixed(2)),
            currency: '\$',
            rating: double.parse(rating.toStringAsFixed(2)),
            reviewCount: reviews,
            salesEstimate: sales,
            monthlyRevenue: revenue,
            opportunityScore: oppScore,
            saturationLevel: satLevel,
            competitionScore: double.parse((1.5 + ((a + m) % 25) * 0.1).toStringAsFixed(1)),
            category: arch.category,
            tags: [...arch.tags, mod.toLowerCase()],
            description: '${arch.description} Handcrafted in limited batches with natural and sustainable ingredients. Perfect as a ${mod.toLowerCase()}.',
            imageUrls: arch.images,
            stockStatus: m % 6 == 0 ? 'Made to Order' : (m % 5 == 0 ? 'Only 3 Left' : 'In Stock'),
            isSaved: count % 19 == 0,
            createdAt: DateTime.now().subtract(Duration(days: (count % 60) + 1)),
          ),
        );
      }
    }
    return products;
  }

  // =========================================================================
  // AMAZON CATALOG GENERATOR (1,000 AUTHENTIC PRODUCTS)
  // =========================================================================
  static List<ProductModel> _generateAmazon() {
    const archetypes = [
      _Archetype(
        baseTitle: 'Echo Dot Compact Smart Speaker with Alexa',
        category: 'Electronics',
        basePrice: 49.99,
        tags: ['smart speaker', 'alexa device', 'bluetooth audio', 'smart home hub', 'voice control'],
        description: 'Best-sounding Echo Dot yet. Enjoy clearer vocals and deeper bass in any room. Ask Alexa for music, weather, and timers, and control compatible smart home devices.',
        images: [
          'https://images.unsplash.com/photo-1543512214-318c7553f230?w=600',
          'https://images.unsplash.com/photo-1589492477829-5e65395b66cc?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Kindle Paperwhite 6.8-inch Glare-Free Display E-Reader',
        category: 'Electronics',
        basePrice: 139.99,
        tags: ['kindle paperwhite', 'ebook reader', 'waterproof e-reader', 'warm light reading', 'glare free screen'],
        description: 'Featuring a 6.8-inch display, thinner borders, adjustable warm light, up to 10 weeks of battery life, and 20% faster page turns. IPX8 waterproof rating.',
        images: [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
          'https://images.unsplash.com/photo-1510519138161-58474dfab9c8?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Active Noise Cancelling Wireless Over-Ear Headphones',
        category: 'Electronics',
        basePrice: 199.00,
        tags: ['anc headphones', 'wireless bluetooth', 'over ear headset', 'hi res audio', 'spatial sound'],
        description: 'Premium dual-processor active noise cancellation blocks ambient aircraft and commuter noise. 40mm drivers deliver deep bass and crystal clear calling clarity.',
        images: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600',
          'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Ninja Pro 4-in-1 Digital Air Fryer with Crisping Plate',
        category: 'Home & Kitchen',
        basePrice: 99.99,
        tags: ['air fryer oven', 'oil free cooking', 'countertop convection', 'crisper plate', 'dishwasher safe'],
        description: 'Convection heat technology circulates superheated air for up to 75% less fat than traditional frying methods. 4-quart nonstick ceramic-coated basket.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Anker Ultra-Compact 20,000mAh Portable Power Bank USB-C PD',
        category: 'Electronics',
        basePrice: 42.99,
        tags: ['power bank', 'usb-c fast charger', 'portable battery pack', '20000mah charger', 'multi device charging'],
        description: 'Colossal 20,000mAh capacity provides over 4 full charges for iPhone and Samsung Galaxy. High-speed PowerIQ 3.0 delivers 20W max fast charging.',
        images: [
          'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=600',
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Logitech MX Master 3S Wireless Performance Ergonomic Mouse',
        category: 'Computers & Accessories',
        basePrice: 99.99,
        tags: ['ergonomic mouse', 'logitech mx master', 'quiet click mouse', 'magSpeed scroll', 'office productivity'],
        description: '8,000 DPI any-surface tracking works seamlessly on glass. Quiet Click switches reduce noise by 90% while MagSpeed electromagnetic scroll wheel scrolls 1,000 lines/sec.',
        images: [
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600',
          'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Stanley Quencher H2.0 FlowState Insulated Stainless Tumbler',
        category: 'Home & Kitchen',
        basePrice: 45.00,
        tags: ['stanley tumbler', 'vacuum insulated cup', 'travel mug with straw', '40oz water bottle', 'cup holder friendly'],
        description: 'Double-wall vacuum insulation keeps iced drinks cold for up to 48 hours. Advanced FlowState lid features rotating cover with 3 splash-resistant positions.',
        images: [
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600',
          'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Bose QuietComfort Wireless Noise-Cancelling Earbuds',
        category: 'Electronics',
        basePrice: 179.00,
        tags: ['noise cancelling earbuds', 'wireless bluetooth buds', 'sweat resistant audio', 'deep acoustic bass', 'commuter earphones'],
        description: 'High-fidelity audio combined with world-class controllable active noise cancellation. StayHear Max silicone tips provide all-day comfortable seal.',
        images: [
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600',
          'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Fitbit Charge 6 Advanced Health & Fitness Tracker',
        category: 'Sports & Outdoors',
        basePrice: 129.95,
        tags: ['fitness tracker', 'heart rate monitor', 'built in gps watch', 'sleep tracking band', 'smart health sensor'],
        description: '60+ exercise modes, built-in GPS, continuous heart rate tracking, EDA stress sensor, and ECG app. Compatible with Google Maps and YouTube Music.',
        images: [
          'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=600',
          'https://images.unsplash.com/photo-1510017803434-a899398421b3?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Oral-B Pro 1000 CrossAction Rechargeable Toothbrush',
        category: 'Beauty & Personal Care',
        basePrice: 49.94,
        tags: ['electric toothbrush', 'rechargeable dental care', 'plaque remover brush', 'pressure sensor timer', 'crossAction bristles'],
        description: 'Clinically proven 300% more plaque removal along gumline. Pressure sensor flashes to protect gums when brushing too hard with in-handle 2-minute timer.',
        images: [
          'https://images.unsplash.com/photo-1559591937-e62fb330bc1f?w=600',
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Instant Pot Duo 7-in-1 Multi-Cooker & Pressure Cooker',
        category: 'Home & Kitchen',
        basePrice: 79.95,
        tags: ['instant pot', 'electric pressure cooker', 'slow cooker yogurt maker', 'stainless steel pot', 'one touch cooking'],
        description: 'Combines 7 kitchen appliances into 1: pressure cooker, slow cooker, rice cooker, steamer, sauté pan, yogurt maker, and food warmer. Cooks up to 70% faster.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'TP-Link Deco WiFi 6 Mesh Whole-Home System',
        category: 'Computers & Accessories',
        basePrice: 149.99,
        tags: ['mesh wifi 6', 'gigabit router', 'whole home coverage', 'seamless roaming', 'gaming wifi extender'],
        description: 'Covers up to 5,800 sq ft with seamless high-speed WiFi 6 up to 3.0 Gbps. Eliminates dead zones and buffers for 150+ connected smart devices.',
        images: [
          'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?w=600',
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Ring Smart Video Doorbell with 1080p HD & Motion Alerts',
        category: 'Tools & Home Improvement',
        basePrice: 99.99,
        tags: ['video doorbell', 'ring security camera', 'two way talk audio', 'smart home security', 'motion detection alerts'],
        description: 'See, hear, and speak to visitors from phone or tablet with 1080p HD video and crisp two-way audio. Improved motion detection with customizable zones.',
        images: [
          'https://images.unsplash.com/photo-1558002038-1055907df827?w=600',
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Cosori Smart Air Fryer Oven with Custom Presets',
        category: 'Home & Kitchen',
        basePrice: 119.99,
        tags: ['cosori air fryer', 'smart kitchen appliance', 'wifi air fryer app', '5.8 qt capacity', 'shake reminder'],
        description: '13 customizable one-touch presets on intuitive LED touch panel. Syncs with smartphone app to monitor cooking progress and browse 100+ recipes.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Blink Outdoor 4 Wireless HD Security Camera System',
        category: 'Tools & Home Improvement',
        basePrice: 89.99,
        tags: ['blink outdoor camera', 'wireless surveillance', 'two year battery life', 'weatherproof camera', 'night vision security'],
        description: 'Wire-free battery-powered 1080p HD security camera that runs for up to two years on included AA lithium batteries. Infrared night vision and cloud recording.',
        images: [
          'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=600',
          'https://images.unsplash.com/photo-1558002038-1055907df827?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'ThermoPro Instant-Read Waterproof Digital Meat Thermometer',
        category: 'Home & Kitchen',
        basePrice: 18.99,
        tags: ['meat thermometer', 'instant read probe', 'digital cooking thermometer', 'bbq smoker probe', 'waterproof kitchen tool'],
        description: 'Ultra-fast 2-3 second reading with high accuracy ±0.9°F. Backlit LCD display with magnetic back and bottle opener for effortless BBQ grilling.',
        images: [
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Hydro Flask Wide Mouth Stainless Insulated Water Bottle',
        category: 'Sports & Outdoors',
        basePrice: 39.95,
        tags: ['hydro flask bottle', 'insulated canteen', 'cold drinks bottle', 'bpa free sports bottle', 'pro grade steel'],
        description: 'TempShield double wall vacuum insulation keeps beverages cold up to 24 hours or hot up to 12. 18/8 pro-grade stainless steel ensures pure taste.',
        images: [
          'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=600',
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600',
        ],
      ),
      _Archetype(
        baseTitle: '7-in-1 Microcurrent Thermal LED Facial Sculpting Wand',
        category: 'Beauty & Personal Care',
        basePrice: 42.99,
        tags: ['red light therapy wand', 'microcurrent facial', 'anti aging skin tool', 'thermal massage roller', 'lymphatic drainage'],
        description: 'Combines 630nm red light phototherapy, soothing therapeutic warmth, facial massage, and galvanic microcurrent to reduce puffiness and fine lines.',
        images: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
          'https://images.unsplash.com/photo-1512290900672-1f41b61c9443?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Modular 45L Tactical Molle Backpack Military Daypack',
        category: 'Sports & Outdoors',
        basePrice: 54.99,
        tags: ['tactical backpack', 'military bug out bag', 'molle rucksack', 'waterproof outdoor pack', 'edc camping gear'],
        description: 'Constructed from 900D waterproof high-density oxford polyester. Multi-compartment interior with hydration bladder sleeve and reinforced webbing.',
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
          'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Deep Tissue Percussion Muscle Massage Gun with 6 Heads',
        category: 'Health & Household',
        basePrice: 49.99,
        tags: ['massage gun', 'deep tissue percussion', 'muscle recovery massager', 'quiet brushless motor', 'fascia gun handheld'],
        description: 'High-torque brushless motor delivers 3200 percussions per minute to relieve muscle stiffness and soreness. 6 interchangeable heads for all muscle groups.',
        images: [
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Ergonomic Memory Foam Lumbar Support Office Pillow',
        category: 'Home & Kitchen',
        basePrice: 29.99,
        tags: ['lumbar support pillow', 'memory foam cushion', 'desk chair backrest', 'ergonomic spine relief', 'breathable mesh cover'],
        description: '100% pure high-density therapeutic memory foam contoured to support the natural curve of lower back. Dual adjustable elastic straps prevent slipping.',
        images: [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
          'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Adjustable Laptop Stand with Heat Dissipation Aluminum Riser',
        category: 'Computers & Accessories',
        basePrice: 27.99,
        tags: ['laptop stand', 'aluminum desk riser', 'ergonomic notebook holder', 'ventilated cooling mount', 'macbook pro stand'],
        description: 'Precision CNC-machined aluminum alloy riser elevates screen to ergonomic eye level. Ventilation hollow design promotes continuous passive airflow.',
        images: [
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600',
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600',
        ],
      ),
      _Archetype(
        baseTitle: '65W GaN Fast Charger Foldable 3-Port Wall Adapter',
        category: 'Electronics',
        basePrice: 32.99,
        tags: ['gan fast charger', '65w usb-c adapter', 'multi port charging brick', 'foldable travel plug', 'laptop phone charger'],
        description: 'Gallium Nitride (GaN) III technology delivers 65W charging output in an ultra-compact body 50% smaller than standard MacBook stock chargers.',
        images: [
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600',
          'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Automatic Pet Water Fountain with Ultra-Quiet Pump & Filter',
        category: 'Pet Supplies',
        basePrice: 25.99,
        tags: ['pet water fountain', 'cat drinking dispenser', 'quiet water pump', 'triple filtration filter', 'stainless steel pet bowl'],
        description: 'Circulating filtration fountain with activated carbon and ion exchange resin sponge. Ultra-silent submersible pump operates below 20 decibels.',
        images: [
          'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=600',
          'https://images.unsplash.com/photo-1535268647677-300dbf3d78d1?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Cordless High-Torque Electric Screwdriver Set Magnetic Bits',
        category: 'Tools & Home Improvement',
        basePrice: 38.99,
        tags: ['electric screwdriver', 'cordless power tool', 'precision magnetic bits', 'usb-c rechargeable tool', 'home diy kit'],
        description: 'Rechargeable 4V lithium-ion screwdriver with 3-stage electronic torque control and dual forward-facing shadowless LED worklights. 30 S2 alloy bits.',
        images: [
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600',
          'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?w=600',
        ],
      ),
    ];

    final modifiers = [
      'Midnight Charcoal Black',
      'Glacier White Edition',
      'Space Gray Metallic',
      'Navy Blue Matte',
      'Rose Gold Aluminum',
      'Bundle with Fast Charging Cable',
      'Pro Max High Capacity Edition',
      'Travel Case & Accessory Kit Included',
      'Dual Pack (Set of 2)',
      'Family 4-Pack Bundle',
      'Upgraded 2026 Chipset',
      'Bluetooth 5.3 & Ultra-Low Latency',
      'Waterproof IPX8 Certified',
      'Extended Battery Life (Up to 40 Hours)',
      'Ultra-Quiet Decibel Motor',
      'Smart App Control & Voice Enabled',
      'Quick-Release Heavy Duty Mount',
      'Stainless Steel 304 Food Grade',
      'BPA-Free Eco-Friendly Polymer',
      'USB-C Power Delivery 100W Compatible',
      'Compact Slim Form Factor',
      'Extra Large 6.5 Quart Capacity',
      'Ergonomic Grip with Wrist Relief',
      'Precision Laser Optical Sensor',
      'Thermal Heat Dissipation Alloy',
      'Auto Shut-Off Safety Sensor',
      'Multi-Angle 360 Degree Rotation',
      'HD 4K Ultra-Clear Resolution',
      'Night Vision Infrared Sensor',
      'Rapid 15-Minute Fast Charge',
      'Replaceable Activated Carbon Filters',
      'Anti-Microbial Silicone Coating',
      'Braided Nylon Tangle-Free Cable',
      'Shockproof Military Drop Tested',
      'Dual-Zone Heating Element',
      'Magnetic MagSafe Compatible',
      'Built-in LED Battery Display',
      'High-Torque 3200 RPM Motor',
      'Adjustable 5-Speed Preset',
      'Commercial Grade Heavy Duty',
    ];

    final shops = [
      {'id': 'shop_amz_01', 'name': 'ApexTactical Gear'},
      {'id': 'shop_amz_02', 'name': 'LuminaGlowWellness'},
      {'id': 'shop_amz_03', 'name': 'EchoAudio Labs'},
      {'id': 'shop_amz_04', 'name': 'PurePeak Living'},
      {'id': 'shop_amz_05', 'name': 'TitanTech Supply'},
      {'id': 'shop_amz_06', 'name': 'AeroBreeze Home'},
      {'id': 'shop_amz_07', 'name': 'Vanguard Electronics'},
      {'id': 'shop_amz_08', 'name': 'NutriCore Organics'},
      {'id': 'shop_amz_09', 'name': 'AeroGear Outdoors'},
      {'id': 'shop_amz_10', 'name': 'OmniGrip Tools'},
    ];

    final products = <ProductModel>[];
    int count = 0;

    for (int a = 0; a < archetypes.length; a++) {
      final arch = archetypes[a];
      for (int m = 0; m < modifiers.length; m++) {
        count++;
        final mod = modifiers[m];
        final id = 'amz_${count.toString().padLeft(4, '0')}';
        final shop = shops[(a + m) % shops.length];
        final priceDelta = ((m % 6) - 2) * 5.0;
        final price = (arch.basePrice + priceDelta).clamp(14.99, 299.99);
        final origPrice = (price * 1.28).roundToDouble();
        final oppScore = 68 + ((a * 5 + m * 7) % 30);
        final satLevel = oppScore >= 87 ? 'Low' : (oppScore >= 77 ? 'Medium' : 'High');
        final rating = (4.50 + ((a * 2 + m) % 45) * 0.01).clamp(4.35, 4.95);
        final reviews = 150 + ((a * 350 + m * 120) % 18500);
        final sales = 300 + ((a * 420 + m * 95) % 12000);
        final revenue = (price * sales * 0.40).roundToDouble();

        products.add(
          ProductModel(
            id: id,
            shopId: shop['id']!,
            shopName: shop['name']!,
            marketplace: 'Amazon',
            title: '${arch.baseTitle} - $mod',
            price: double.parse(price.toStringAsFixed(2)),
            originalPrice: double.parse(origPrice.toStringAsFixed(2)),
            currency: '\$',
            rating: double.parse(rating.toStringAsFixed(2)),
            reviewCount: reviews,
            salesEstimate: sales,
            monthlyRevenue: revenue,
            opportunityScore: oppScore,
            saturationLevel: satLevel,
            competitionScore: double.parse((2.0 + ((a + m) % 25) * 0.1).toStringAsFixed(1)),
            category: arch.category,
            tags: [...arch.tags, mod.toLowerCase()],
            description: '${arch.description} Backed by comprehensive Prime fulfillment with 30-day money-back guarantee. Features $mod.',
            imageUrls: arch.images,
            stockStatus: m % 7 == 0 ? 'Only 2 Left in Stock' : 'In Stock',
            isSaved: count % 17 == 0,
            createdAt: DateTime.now().subtract(Duration(days: (count % 55) + 1)),
          ),
        );
      }
    }
    return products;
  }

  // =========================================================================
  // EBAY CATALOG GENERATOR (1,000 AUTHENTIC PRODUCTS)
  // =========================================================================
  static List<ProductModel> _generateEbay() {
    const archetypes = [
      _Archetype(
        baseTitle: 'Sony PlayStation 5 Disc Edition Gaming Console',
        category: 'Video Games & Consoles',
        basePrice: 429.00,
        tags: ['ps5 console', 'playstation 5 disc', 'sony gaming system', 'refurbished console', 'next gen gaming'],
        description: 'Ultra-high speed SSD with integrated I/O, custom AMD GPU/CPU, and ray tracing. Tested, cleaned, and authenticated by certified refurbishers.',
        images: [
          'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600',
          'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Nintendo Game Boy Advance SP Handheld System',
        category: 'Video Games & Consoles',
        basePrice: 165.00,
        tags: ['game boy advance sp', 'gba sp ips mod', 'retro nintendo handheld', 'gameboy custom', 'pokemon emerald gba'],
        description: 'Classic folding clamshell console updated with crisp modern V2 IPS backlit screen. Features adjustable brightness levels, new speaker, and USB-C port.',
        images: [
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
          'https://images.unsplash.com/photo-1531525645387-7f14be1bdbbd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Nike Air Jordan 1 Retro High OG Vintage Colorway',
        category: 'Clothing & Shoes',
        basePrice: 220.00,
        tags: ['air jordan 1 retro', 'chicago 1985 dunk', 'collectible sneakers', 'og high top', 'deadstock kicks'],
        description: 'Iconic high-top basketball sneaker built with premium leather uppers and encapsulated Nike Air cushioning. Verified with eBay Authenticity Guarantee tag.',
        images: [
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600',
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600',
        ],
      ),
      _Archetype(
        baseTitle: '1999 Pokemon Base Set 1st Edition Charizard Holo Card',
        category: 'Art & Collectibles',
        basePrice: 380.00,
        tags: ['charizard 1st edition', 'base set holo', 'pokemon card psa', 'shadowless vintage', 'wotc trading card'],
        description: 'The pinnacle of vintage trading cards. Wizards of the Coast 1999 Base Set Holofoil Charizard #4/102. Encapsulated in tamper-evident sonic weld slab.',
        images: [
          'https://images.unsplash.com/photo-1613771404784-3a5686aa2be3?w=600',
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vintage Casio G-Shock DW-5600 Japan 200M Diver Watch',
        category: 'Jewelry & Watches',
        basePrice: 115.00,
        tags: ['casio g-shock vintage', 'dw5600 japan h', 'square digital watch', 'speed movie watch', 'military rugged timer'],
        description: 'Classic screwback steel case square digital diver made in Japan. Original 200m water resistance with shock absorbing inner resin module and mineral crystal.',
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600',
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Seiko SKX007 Automatic Diver 200M Tool Watch',
        category: 'Jewelry & Watches',
        basePrice: 285.00,
        tags: ['seiko skx007', 'automatic diver watch', '7s26 movement', 'hardlex crystal', 'iso certified diver'],
        description: 'Legendary ISO-certified automatic dive watch powered by the bulletproof 7S26 movement. Uni-directional 120-click rotating bezel with Lumibrite dial markers.',
        images: [
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600',
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Apple iPhone 13 Pro 256GB Factory Unlocked Smartphone',
        category: 'Cell Phones & Accessories',
        basePrice: 489.00,
        tags: ['iphone 13 pro', 'apple unlocked phone', 'proMotion 120hz', 'triple camera system', 'certified refurbished phone'],
        description: 'A15 Bionic chip with 6-core GPU, ProMotion 120Hz Super Retina XDR OLED display, and cinematic video mode. 100% functional with clean IMEI.',
        images: [
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600',
          'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Canon EOS Rebel T7 DSLR Camera with 18-55mm IS II Lens',
        category: 'Cameras & Photo',
        basePrice: 349.00,
        tags: ['canon dslr camera', 'eos rebel t7 kit', 'ef-s lens bundle', '24mp photography', 'optical viewfinder dslr'],
        description: '24.1 Megapixel CMOS sensor with DIGIC 4+ image processor. Includes EF-S 18-55mm f/3.5-5.6 IS II lens, battery charger, and neck strap.',
        images: [
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Original 1977 Star Wars Episode IV A New Hope Movie Poster',
        category: 'Collectibles',
        basePrice: 195.00,
        tags: ['star wars 1977 poster', 'vintage theatrical print', 'george lucas memorabilia', 'sci-fi movie collectibles', 'style a movie one sheet'],
        description: 'Original theatrical release 27x41 inches one-sheet poster featuring classic Tom Jung illustration. Grade A preservation with sharp crisp colors.',
        images: [
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600',
          'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vintage Bose 901 Series VI Direct/Reflecting Speaker Pair',
        category: 'Consumer Electronics',
        basePrice: 380.00,
        tags: ['bose 901 speakers', 'vintage audiophile hi fi', 'direct reflecting sound', 'active equalizer bose', 'mid century speakers'],
        description: 'Legendary 9-driver acoustic matrix loudspeaker enclosures. Delivers lifelike spacious stereo imaging that reflects off surrounding room walls.',
        images: [
          'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600',
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Sega Dreamcast Console System with GDEMU Flash Drive',
        category: 'Video Games & Consoles',
        basePrice: 185.00,
        tags: ['sega dreamcast', 'gdemu optical mod', 'retro sega console', 'dc bios mod', 'vmu controller sega'],
        description: 'Japanese VA1 revision motherboard modified with GDEMU optical drive emulator. Replaced clock battery, silent Noctua cooling fan, and HDMI kit.',
        images: [
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
          'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vintage 1970s Fender Stratocaster Electric Guitar',
        category: 'Musical Instruments',
        basePrice: 850.00,
        tags: ['fender stratocaster vintage', '70s electric guitar', 'large headstock strat', 'ash body sunburst', 'single coil pickups'],
        description: 'Original 1970s large headstock 3-bolt neck Stratocaster with natural resonant ash body and maple neck. Verified electronics with period original case.',
        images: [
          'https://images.unsplash.com/photo-1516924962500-2b4b3b99ea02?w=600',
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Sony Walkman WM-D6C Professional Stereo Cassette Recorder',
        category: 'Consumer Electronics',
        basePrice: 420.00,
        tags: ['sony walkman wm-d6c', 'vintage cassette player', 'pro walkman recorder', 'dolby c noise reduction', 'audiophile tape deck'],
        description: 'Regarded as the finest portable analog cassette player ever engineered. Quartz-locked capstan servo, amorphous head, and calibrated tape bias.',
        images: [
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Nintendo 64 N64 Funtastic Colored Transparent Console',
        category: 'Video Games & Consoles',
        basePrice: 175.00,
        tags: ['n64 funtastic', 'nintendo 64 transparent', 'smoke grey n64', 'expansion pak n64', 'vintage 64 console'],
        description: 'OEM authentic Funtastic translucent shell console thoroughly ultrasonically cleaned. Includes official matching tight joystick controller and jumper pak.',
        images: [
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
          'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vintage Levi 501 Selvedge Redline Denim Jeans Made in USA',
        category: 'Clothing & Shoes',
        basePrice: 160.00,
        tags: ['vintage levis 501', 'selvedge redline denim', 'made in usa vintage', 'single stitch levis', 'cone mills denim'],
        description: 'Authentic 1980s Cone Mills white oak redline selvedge 501 straight leg jeans with copper rivets and button fly. Genuine historical whiskers and fades.',
        images: [
          'https://images.unsplash.com/photo-1542272604-780c96856592?w=600',
          'https://images.unsplash.com/photo-1582552938357-32b906df40cb?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Yu-Gi-Oh! Blue-Eyes White Dragon 1st Edition Ultra Rare Card',
        category: 'Art & Collectibles',
        basePrice: 275.00,
        tags: ['blue eyes white dragon', 'lob-001 1st edition', 'yugioh vintage card', 'konami ultra rare', 'graded yugioh psa'],
        description: 'Legend of Blue-Eyes White Dragon (LOB-001) ultra rare English printing. Exceptional holo foil reflection and centered borders.',
        images: [
          'https://images.unsplash.com/photo-1613771404784-3a5686aa2be3?w=600',
          'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Leica M6 Classic 35mm Rangefinder Film Camera Body',
        category: 'Cameras & Photo',
        basePrice: 1250.00,
        tags: ['leica m6 classic', '35mm film rangefinder', 'leitz wetzlar camera', 'mechanical camera body', 'street photography leica'],
        description: 'Iconic mechanical rangefinder camera body with 0.72x magnification viewfinder and built-in TTL light metering. Smooth advance lever and calibrated shutter.',
        images: [
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600',
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Microsoft Xbox 360 Limited Edition Console in Box',
        category: 'Video Games & Consoles',
        basePrice: 195.00,
        tags: ['xbox 360 halo edition', 'vintage gaming console', 'complete in box cib', 'jasper motherboard', 'wireless 360 controller'],
        description: 'Collector-grade complete in box system with matching metallic Spartan green casing, original power supply, AV cables, and manual documentation.',
        images: [
          'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600',
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Technics SL-1200MK2 Direct Drive Professional DJ Turntable',
        category: 'Consumer Electronics',
        basePrice: 520.00,
        tags: ['technics sl-1200mk2', 'direct drive turntable', 'vinyl dj deck', 'quartz pitch control', 'audiophile record player'],
        description: 'Industry benchmark direct-drive turntable featuring precision quartz-lock slider, vibration-damping heavy rubber base, and S-shaped tonearm.',
        images: [
          'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600',
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Nike Dunk Low Retro Panda B-Ball Sneaker',
        category: 'Clothing & Shoes',
        basePrice: 135.00,
        tags: ['nike dunk low panda', 'black white dunks', 'retro streetwear sneaker', 'low top b-ball', 'verified authentic shoes'],
        description: 'Crisp black and white leather color blocking on low-profile padded collar and durable rubber outsole. Verified through eBay sneaker authentication vault.',
        images: [
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600',
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600',
        ],
      ),
      _Archetype(
        baseTitle: '1986 Fleer Michael Jordan Rookie Card #57 Basketball',
        category: 'Art & Collectibles',
        basePrice: 950.00,
        tags: ['michael jordan rookie', '1986 fleer 57', 'nba basketball card', 'chicago bulls vintage', 'graded rookie card'],
        description: 'The holy grail of modern basketball cards. Features iconic Michael Jordan rookie high-flying slam dunk action shot. Encapsulated in protective slab.',
        images: [
          'https://images.unsplash.com/photo-1613771404784-3a5686aa2be3?w=600',
          'https://images.unsplash.com/photo-1519766304817-4f37bda74a29?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Game Boy Color Handheld Console with Q5 IPS Screen Mod',
        category: 'Video Games & Consoles',
        basePrice: 145.00,
        tags: ['game boy color mod', 'q5 ips screen gbc', 'illuminated retro console', 'custom atomic purple', 'pokemon crystal gbc'],
        description: 'Original motherboard recap with laminated high-contrast IPS LCD screen displaying 15% larger viewing area with retro pixel grid filter modes.',
        images: [
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
          'https://images.unsplash.com/photo-1531525645387-7f14be1bdbbd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Omega Seamaster Automatic Vintage 1960s Swiss Watch',
        category: 'Jewelry & Watches',
        basePrice: 720.00,
        tags: ['omega seamaster vintage', 'cal 565 automatic', 'swiss luxury watch', 'pie pan crosshair dial', 'stainless steel omega'],
        description: 'Classic 35mm stainless steel case with legendary in-house Calibre 565 automatic movement. Silver sunburst dial with applied steel baton markers.',
        images: [
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600',
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Polaroid SX-70 Original Folding Instant SLR Film Camera',
        category: 'Cameras & Photo',
        basePrice: 230.00,
        tags: ['polaroid sx-70', 'folding instant camera', 'vintage polaroid slr', 'glass lens polaroid', 'brown leather camera'],
        description: 'Collapsible single-lens reflex instant camera with 4-element 116mm f/8 glass lens and brushed chrome body wrapped in genuine tan leather.',
        images: [
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600',
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Marvel The Amazing Spider-Man #300 1st Appearance Venom',
        category: 'Collectibles',
        basePrice: 320.00,
        tags: ['amazing spider-man 300', '1st venom comic', 'todd mcfarlane art', 'marvel copper age', 'cgc graded comic'],
        description: 'Milestone 25th anniversary issue featuring Todd McFarlane cover art and full origin appearance of Venom. White pages with pristine gloss.',
        images: [
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600',
          'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
        ],
      ),
    ];

    final modifiers = [
      'PSA 10 Gem Mint Graded',
      'PSA 9 Mint Condition',
      'BGS 9.5 Gem Mint with Subgrades',
      'CGC 9.8 Near Mint / Mint Graded',
      'Factory Refurbished - Grade A+ Pristine',
      'Certified Refurbished - 2-Year Warranty',
      'Custom V2 IPS Backlit Screen Mod (USB-C Battery)',
      'Deadstock Brand New with Original Box & Tags',
      'Authenticity Guarantee Verified',
      'Original Box, Manuals & Inserts Complete',
      'Serviced & Recapped with Audiophile Components',
      'First Print Collector Rare Variant',
      'Shadowless Holographic 1st Edition',
      'Japanese Import Region-Free Mod',
      'Smoke Grey Transparent Shell Edition',
      'Jubilee Solid Stainless Steel Bracelet',
      'Restored Shutter & New Light Seals',
      'Battery Health 98% - Clean IMEI',
      'Original 1985 Release with Certificate of Authenticity',
      'Signed by Creator with Beckett COA',
      'Direct Drive Calibrated Pitch Quartz Lock',
      'Onyx Black Custom Matte Housing',
      'Midnight Navy Blue Limited Run',
      'Solid Silver Sterling Trim',
      'Pre-Owned Excellent Condition (Tested 100%)',
      'Never Played Vault Copy',
      'Includes 2 OEM Original Wireless Controllers',
      'Bundled with 5 Classic Top Games',
      'Vintage Patina Dial Original Hands',
      'Single Stitch 100% Cotton Made in USA',
      'Raw Uncut Proof Card',
      'Gold Foil Stamp Special Edition',
      'Heavy Relic Finish Custom Shop',
      'New Old Stock (NOS) Sealed',
      'Custom Aluminum CNC Machined Shell',
      'Retro Bright De-Yellowed Treatment',
      'Includes High-End Hard Shell Flight Case',
      'Fresh CLA Service Performed',
      'Low Serial Number #042/500',
      'Collector Grade Investment Asset',
    ];

    final shops = [
      {'id': 'shop_ebay_01', 'name': 'RetroTechVault'},
      {'id': 'shop_ebay_02', 'name': 'SneakerVaultDirect'},
      {'id': 'shop_ebay_03', 'name': 'RetroPixelArchive'},
      {'id': 'shop_ebay_04', 'name': 'VintageTimepieceUK'},
      {'id': 'shop_ebay_05', 'name': 'CollectorCardsPro'},
      {'id': 'shop_ebay_06', 'name': 'TokyoCameraOutlet'},
      {'id': 'shop_ebay_07', 'name': 'KantoCollectibles'},
      {'id': 'shop_ebay_08', 'name': 'AudioVaultClassics'},
      {'id': 'shop_ebay_09', 'name': 'NipponRetroVault'},
      {'id': 'shop_ebay_10', 'name': 'PacificCollectibles'},
    ];

    final products = <ProductModel>[];
    int count = 0;

    for (int a = 0; a < archetypes.length; a++) {
      final arch = archetypes[a];
      for (int m = 0; m < modifiers.length; m++) {
        count++;
        final mod = modifiers[m];
        final id = 'ebay_${count.toString().padLeft(4, '0')}';
        final shop = shops[(a + m) % shops.length];
        final priceDelta = ((m % 5) - 2) * 8.0;
        final price = (arch.basePrice + priceDelta).clamp(29.00, 1450.00);
        final origPrice = (price * 1.20).roundToDouble();
        final oppScore = 72 + ((a * 6 + m * 4) % 26);
        final satLevel = oppScore >= 89 ? 'Low' : (oppScore >= 79 ? 'Medium' : 'High');
        final rating = (4.80 + ((a + m) % 20) * 0.01).clamp(4.75, 5.00);
        final reviews = 25 + ((a * 85 + m * 24) % 1800);
        final sales = 60 + ((a * 95 + m * 33) % 2400);
        final revenue = (price * sales * 0.25).roundToDouble();

        products.add(
          ProductModel(
            id: id,
            shopId: shop['id']!,
            shopName: shop['name']!,
            marketplace: 'eBay',
            title: '${arch.baseTitle} - $mod',
            price: double.parse(price.toStringAsFixed(2)),
            originalPrice: double.parse(origPrice.toStringAsFixed(2)),
            currency: '\$',
            rating: double.parse(rating.toStringAsFixed(2)),
            reviewCount: reviews,
            salesEstimate: sales,
            monthlyRevenue: revenue,
            opportunityScore: oppScore,
            saturationLevel: satLevel,
            competitionScore: double.parse((1.4 + ((a + m) % 22) * 0.1).toStringAsFixed(1)),
            category: arch.category,
            tags: [...arch.tags, mod.toLowerCase()],
            description: '${arch.description} Professionally inspected, packaged in bubble wrap and double boxed for safe collector transit. Condition: $mod.',
            imageUrls: arch.images,
            stockStatus: m % 4 == 0 ? 'Only 1 Left' : 'In Stock',
            isSaved: count % 16 == 0,
            createdAt: DateTime.now().subtract(Duration(days: (count % 50) + 1)),
          ),
        );
      }
    }
    return products;
  }

  // =========================================================================
  // SHOPIFY CATALOG GENERATOR (1,000 AUTHENTIC PRODUCTS)
  // =========================================================================
  static List<ProductModel> _generateShopify() {
    const archetypes = [
      _Archetype(
        baseTitle: 'Gymshark Seamless Vital Lightweight Training Leggings',
        category: 'Fashion & Apparel',
        basePrice: 54.00,
        tags: ['gymshark leggings', 'seamless gym tights', 'squat proof workout wear', 'high waisted fitness', 'd2c activewear'],
        description: 'Breathable sweat-wicking knit with four-way stretch and supportive ribbed waistband. Seamless shading contours and flatters athletic silhouettes.',
        images: [
          'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=600',
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Allbirds Men Wool Runners Merino Wool Everyday Sneakers',
        category: 'Fashion & Apparel',
        basePrice: 110.00,
        tags: ['allbirds runners', 'merino wool sneakers', 'sustainable shoes', 'cloud foam sole', 'breathable footwear'],
        description: 'Super-soft ZQ-certified merino wool upper offers next-level comfort with moisture-wicking and odor-resistant properties. Machine washable.',
        images: [
          'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=600',
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'The Ridge Minimalist Slim RFID-Blocking Metal Wallet',
        category: 'Accessories & Gear',
        basePrice: 85.00,
        tags: ['ridge wallet', 'rfid blocking wallet', 'minimalist card holder', 'aircraft grade metal', 'cash strap clip'],
        description: 'Dual-track metal plate construction expands to hold 1-12 cards without stretching. Integrated elastic cash strap with lifetime guarantee.',
        images: [
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600',
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'MVMT Classic Monochrome 45mm Minimalist Quartz Watch',
        category: 'Accessories & Gear',
        basePrice: 125.00,
        tags: ['mvmt watch', 'minimalist timepiece', 'matte black quartz', 'interchangeable leather band', 'clean dial watch'],
        description: 'Brushed stainless steel 45mm case with hardened mineral crystal. Miyota precision Japanese quartz movement paired with genuine leather quick-release strap.',
        images: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600',
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Huel Daily Greens 91-in-1 Nutrient Superfood Powder',
        category: 'Health & Wellness',
        basePrice: 50.00,
        tags: ['huel daily greens', 'superfood powder', 'adaptogens vitamins', 'gut health prebiotic', 'plant based nutrition'],
        description: '91 whole-food-sourced ingredients including adaptogens, digestive enzymes, dairy-free probiotics, organic greens, and antioxidant berries.',
        images: [
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
          'https://images.unsplash.com/photo-1512290900672-1f41b61c9443?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Glossier Boy Brow Volumizing Eyebrow Grooming Pomade',
        category: 'Beauty & Cosmetics',
        basePrice: 22.00,
        tags: ['glossier boy brow', 'eyebrow pomade', 'fluffy brows', 'clean beauty grooming', 'conditioning brow wax'],
        description: 'Inspired by traditional hair pomade, this creamy conditioning formula gives brows flexible, soft hold that doesn\'t stiffen or flake. Contains oleic acid and beeswax.',
        images: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
          'https://images.unsplash.com/photo-1512290900672-1f41b61c9443?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Casper Original Ergonomic Cooling Pillow Dual Foam',
        category: 'Home & Furniture',
        basePrice: 65.00,
        tags: ['casper pillow', 'ergonomic neck support', 'cooling foam pillow', 'breathable pillowcase', 'restful sleep'],
        description: 'Unique pillow-in-a-pillow design combines responsive supportive inner core with plush, fluffy outer layer. Breathable percale weave stays cool all night.',
        images: [
          'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600',
          'https://images.unsplash.com/photo-1554995207-c18c20360250?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Quad Lock Out-Front Bike Handlebar Phone Mount Kit',
        category: 'Accessories & Gear',
        basePrice: 49.95,
        tags: ['quad lock mount', 'bike handlebar holder', 'cycling phone clip', 'secure twist lock', 'road bike tech'],
        description: 'Patented dual-stage locking mechanism secures phone safely over potholes and rough terrain. Low profile aerodynamic design sits flush with handlebars.',
        images: [
          'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=600',
          'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Ceremonial Grade Uji Japanese Organic Matcha Green Tea',
        category: 'Food & Beverage',
        basePrice: 38.00,
        tags: ['ceremonial matcha', 'uji green tea powder', 'first harvest matcha', 'l-theanine calm energy', 'organic japanese tea'],
        description: 'First spring harvest shade-grown tea leaves stone-milled in Uji, Kyoto. Vibrant electric jade color with velvety smooth umami taste and no bitterness.',
        images: [
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=600',
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Chamberlain Coffee Early Bird Medium Roast Whole Bean',
        category: 'Food & Beverage',
        basePrice: 20.00,
        tags: ['chamberlain coffee', 'organic whole bean', 'specialty medium roast', 'sweet citrus notes', 'artisan roasted blend'],
        description: '100% organic Arabica beans ethically sourced from high-altitude micro-lots in Colombia and Guatemala. Tasting notes of milk chocolate, crisp green apple, and honey.',
        images: [
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
          'https://images.unsplash.com/photo-1559525839-8f8303f8f110?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Caraway Non-Toxic Ceramic Non-Stick Sauté Pan with Lid',
        category: 'Home & Furniture',
        basePrice: 145.00,
        tags: ['caraway sauté pan', 'non toxic cookware', 'ceramic non stick', 'ptfe pfoa free', 'modern kitchen skillet'],
        description: 'Naturally slick mineral-based ceramic coating requires less oil for cooking and minimal cleanup. Compatible with all stovetops including gas, electric, and induction.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Oura Ring Gen 3 Horizon Smart Health & Sleep Tracker',
        category: 'Accessories & Gear',
        basePrice: 299.00,
        tags: ['oura ring gen 3', 'smart health ring', 'sleep tracker titanium', 'hrv temperature sensor', 'readiness score ring'],
        description: 'Sleek lightweight titanium smart ring monitoring sleep stages, blood oxygen (SpO2), heart rate variability, skin temperature trends, and daytime recovery.',
        images: [
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600',
          'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Cuts Clothing AO Curve-Hem Luxury Pima Cotton T-Shirt',
        category: 'Fashion & Apparel',
        basePrice: 58.00,
        tags: ['cuts clothing tee', 'pima cotton shirt', 'curve hem crewneck', 'wrinkle free travel shirt', 'tailored fit tee'],
        description: 'Proprietary Pyca Pro custom fabric blend combines the buttery softness of Supima cotton with four-way stretch and color retention shape memory.',
        images: [
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600',
          'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Away The Bigger Carry-On Suitcase with Ejectable Battery',
        category: 'Accessories & Gear',
        basePrice: 295.00,
        tags: ['away carry on luggage', 'polycarbonate suitcase', '360 spinner wheels', 'tsa lock travel bag', 'compression luggage'],
        description: 'Durable aerospace-grade polycarbonate hard shell engineered to flex under pressure. Features whisper-quiet 360° spinner wheels and interior compression system.',
        images: [
          'https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=600',
          'https://images.unsplash.com/photo-1581553680321-4fffae59fccd?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Vuori Kore 7-inch Moisture-Wicking Athletic Shorts',
        category: 'Fashion & Apparel',
        basePrice: 68.00,
        tags: ['vuori kore shorts', 'athletic training shorts', 'built in boxer brief', 'moisture wicking gym', 'sustainable stretch short'],
        description: 'Ultra-lightweight four-way stretch performance shorts featuring an integrated breathable boxer brief liner. Quick-drying and anti-odor for running or yoga.',
        images: [
          'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600',
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Magic Spoon High-Protein Low-Carb Healthy Cereal',
        category: 'Food & Beverage',
        basePrice: 39.00,
        tags: ['magic spoon cereal', 'keto friendly breakfast', 'high protein cereal', 'zero sugar snack', 'gluten free crunch'],
        description: 'Childhood nostalgia remade for modern nutrition. 13g protein and only 4g net carbs per bowl with zero cane sugar or artificial sweeteners.',
        images: [
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Brooklinen Luxe Sateen 480 Thread Count Bed Sheet Set',
        category: 'Home & Furniture',
        basePrice: 169.00,
        tags: ['brooklinen sheets', 'luxe sateen bedding', 'long staple cotton', '480 thread count sheets', 'hotel quality bedding'],
        description: 'Woven from 100% long-staple cotton with a luminous sateen weave that feels silky and smooth against skin. Certified OEKO-TEX free of harmful chemicals.',
        images: [
          'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=600',
          'https://images.unsplash.com/photo-1554995207-c18c20360250?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Liquid Death Mountain Water with Electrolytes',
        category: 'Food & Beverage',
        basePrice: 17.99,
        tags: ['liquid death water', 'canned mountain water', 'infinitely recyclable cans', 'austrian alps spring', 'eco hydration'],
        description: '100% natural mountain water sourced from deep beneath stone in the Austrian Alps. Canned in infinitely recyclable king-sized aluminum tallboys.',
        images: [
          'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=600',
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Bellroy Transit 28L Water-Resistant Everyday Backpack',
        category: 'Accessories & Gear',
        basePrice: 239.00,
        tags: ['bellroy transit bag', 'edc commuter backpack', 'recycled woven fabric', 'padded laptop sleeve 16', 'minimalist travel pack'],
        description: 'Cleverly organized commuter bag with separate 16-inch padded laptop access, hidden passport pocket, and contoured breathable foam harness straps.',
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
          'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Beast Health 1000W Ultra-Quiet Blender System',
        category: 'Home & Furniture',
        basePrice: 165.00,
        tags: ['beast blender', 'nutrient extraction blender', 'fluted ribbed glass vessel', 'smoothie blender system', 'aesthetic countertop appliance'],
        description: 'Precision ribbed 12-flute glass vessel creates internal vortex for silky smooth blending. Real-time temperature control avoids overheating sensitive raw nutrients.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Dr. Squatch Natural Cold-Process Pine Tar Bar Soap',
        category: 'Beauty & Cosmetics',
        basePrice: 12.00,
        tags: ['dr squatch soap', 'natural pine tar bar', 'exfoliating body soap', 'cold process soap', 'mens natural grooming'],
        description: 'Heavy grit body soap crafted with real pine extract, shea butter, and oatmeal. Natural exfoliating particles remove dead skin while leaving a rugged woodsy scent.',
        images: [
          'https://images.unsplash.com/photo-1607006314181-7917730e176b?w=600',
          'https://images.unsplash.com/photo-1512290900672-1f41b61c9443?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Supply Single-Edge Stainless Steel Precision Safety Razor',
        category: 'Beauty & Cosmetics',
        basePrice: 69.00,
        tags: ['supply single edge razor', 'stainless steel safety razor', 'zero irritation shave', 'close mens shave', 'eco shaving kit'],
        description: 'Solid surgical-grade die-cast zinc razor with NickStop technology. Single blade cuts hair cleanly at surface level without causing ingrown hairs or razor burn.',
        images: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
          'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Native Aluminum-Free Sensitive Skin Deodorant',
        category: 'Beauty & Cosmetics',
        basePrice: 13.00,
        tags: ['native deodorant', 'aluminum free deodorant', 'baking soda free', 'coconut vanilla stick', 'natural body care'],
        description: 'Clean, simple, non-toxic formula made without aluminum, parabens, or sulfates. Infused with coconut oil, shea butter, and tapioca starch for all-day odor protection.',
        images: [
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600',
          'https://images.unsplash.com/photo-1512290900672-1f41b61c9443?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Fellow Ode Gen 2 Precision Electric Coffee Burr Grinder',
        category: 'Home & Furniture',
        basePrice: 345.00,
        tags: ['fellow ode grinder', '64mm flat burrs', 'specialty coffee grinder', 'low retention hopper', 'single dose coffee'],
        description: 'Commercial-grade 64mm stainless steel flat burrs with 31 stepped grind settings. Auto-stop sensor detects when beans have completed grinding cycle.',
        images: [
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
        ],
      ),
      _Archetype(
        baseTitle: 'Our Place Always Pan 8-in-1 Ceramic Non-Stick Skillet',
        category: 'Home & Furniture',
        basePrice: 150.00,
        tags: ['our place always pan', '8-in-1 cooking skillet', 'ceramic non stick pan', 'modular spatula rest', 'aesthetic dinnerware'],
        description: 'Replaces your fry pan, sauté pan, steamer, skillet, saucier, nonstick pan, and spoon rest. Toxic-free nonstick coating made without PFAS, lead, or cadmium.',
        images: [
          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=600',
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600',
        ],
      ),
    ];

    final modifiers = [
      'Matte Midnight Black',
      'Natural Raw Earth Oat',
      'Sage Green Botanical',
      'Terracotta Clay Limited Colorway',
      'Deep Ocean Navy',
      'Brushed Gunmetal Titanium',
      'D2C Direct Starter Bundle',
      'Subscription Refill Pack (30-Day Supply)',
      'Limited Collaboration Edition',
      'Sustainable Recycled Materials Series',
      'Pro Athlete Performance Line',
      'Ultra-Soft Brushed Finish',
      'Organic Certified Non-GMO',
      'Clean Ingredient Cruelty-Free',
      'Compact Weekender Travel Size',
      'Dual-Tone Contrast Trim',
      'Carbon Neutral Certified',
      'Waterproof Ballistic Nylon',
      'Includes Custom Magnetic Accessories',
      'Zero Sugar Keto Friendly',
      '100% Biodegradable Eco Packaging',
      'Luxury Gift Box Packaging',
      '4-Pack Variety Sampler',
      'Family Size Bulk Economy Pack',
      'Ergonomic Contoured Fit',
      'Aerospace Grade 6061-T6 Aluminum',
      'Temperature Regulating Breathable Weave',
      'Rapid Moisture Wicking 4-Way Stretch',
      'Anti-Odor Silver Ion Infusion',
      'Ceramic Non-Stick Toxic-Free PTFE/PFOA Free',
      'Barista Special Edition',
      'Cold Brew Grind Formulation',
      'Unflavored Pure Base',
      'Vanilla Bean & Himalayan Salt',
      'Dark Chocolate Sea Salt',
      'Cedarwood & Mountain Sage',
      'Bergamot & Sandalwood',
      'Ultra-Lightweight 120g Profile',
      'Modular Quick-Release System',
      'Signature Founder\'s Collection',
    ];

    final shops = [
      {'id': 'shop_shopify_01', 'name': 'NordicHavenLiving'},
      {'id': 'shop_shopify_02', 'name': 'Gymshark Official'},
      {'id': 'shop_shopify_03', 'name': 'Allbirds Direct'},
      {'id': 'shop_shopify_04', 'name': 'Ridge Goods Co'},
      {'id': 'shop_shopify_05', 'name': 'MVMT Watches'},
      {'id': 'shop_shopify_06', 'name': 'Glossier Studio'},
      {'id': 'shop_shopify_07', 'name': 'Caraway Home'},
      {'id': 'shop_shopify_08', 'name': 'Vuori Performance'},
      {'id': 'shop_shopify_09', 'name': 'Away Travel Co'},
      {'id': 'shop_shopify_10', 'name': 'Chamberlain Coffee'},
    ];

    final products = <ProductModel>[];
    int count = 0;

    for (int a = 0; a < archetypes.length; a++) {
      final arch = archetypes[a];
      for (int m = 0; m < modifiers.length; m++) {
        count++;
        final mod = modifiers[m];
        final id = 'shopify_${count.toString().padLeft(4, '0')}';
        final shop = shops[(a + m) % shops.length];
        final priceDelta = ((m % 5) - 2) * 4.0;
        final price = (arch.basePrice + priceDelta).clamp(11.00, 395.00);
        final origPrice = (price * 1.22).roundToDouble();
        final oppScore = 74 + ((a * 8 + m * 5) % 25);
        final satLevel = oppScore >= 88 ? 'Low' : (oppScore >= 78 ? 'Medium' : 'High');
        final rating = (4.70 + ((a + m * 2) % 30) * 0.01).clamp(4.60, 4.98);
        final reviews = 80 + ((a * 140 + m * 45) % 4500);
        final sales = 180 + ((a * 190 + m * 70) % 7800);
        final revenue = (price * sales * 0.38).roundToDouble();

        products.add(
          ProductModel(
            id: id,
            shopId: shop['id']!,
            shopName: shop['name']!,
            marketplace: 'Shopify',
            title: '${arch.baseTitle} - $mod',
            price: double.parse(price.toStringAsFixed(2)),
            originalPrice: double.parse(origPrice.toStringAsFixed(2)),
            currency: '\$',
            rating: double.parse(rating.toStringAsFixed(2)),
            reviewCount: reviews,
            salesEstimate: sales,
            monthlyRevenue: revenue,
            opportunityScore: oppScore,
            saturationLevel: satLevel,
            competitionScore: double.parse((1.8 + ((a + m) % 20) * 0.1).toStringAsFixed(1)),
            category: arch.category,
            tags: [...arch.tags, mod.toLowerCase()],
            description: '${arch.description} Shipped in direct-to-consumer eco-conscious custom packaging. Edition: $mod.',
            imageUrls: arch.images,
            stockStatus: m % 6 == 0 ? 'Backorder - Ships in 5 Days' : 'In Stock',
            isSaved: count % 18 == 0,
            createdAt: DateTime.now().subtract(Duration(days: (count % 60) + 1)),
          ),
        );
      }
    }
    return products;
  }
}

class _Archetype {
  final String baseTitle;
  final String category;
  final double basePrice;
  final List<String> tags;
  final String description;
  final List<String> images;

  const _Archetype({
    required this.baseTitle,
    required this.category,
    required this.basePrice,
    required this.tags,
    required this.description,
    required this.images,
  });
}
