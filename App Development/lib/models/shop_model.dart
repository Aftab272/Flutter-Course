class ShopModel {
  final String id;
  final String name;
  final String marketplace; // 'Etsy', 'Amazon', 'eBay', 'Shopify'
  final String url;
  final String logoUrl;
  final double rating;
  final int reviewCount;
  final int totalSales;
  final double monthlyRevenueEst;
  final String country;
  final int openYear;
  final int totalListings;
  final int activeListings;
  final int inactiveListings;
  final int totalOrders;
  final double netPayout;
  final String payoutCurrency;
  final double avgPrice;
  final List<String> topCategories;
  final List<String> topTags;
  final List<String> badges;
  final bool isSaved;
  final int opportunityScore;
  final String description;
  final String ownerName;
  final String ownerAvatarUrl;
  final String listingDate;

  const ShopModel({
    required this.id,
    required this.name,
    required this.marketplace,
    required this.url,
    required this.logoUrl,
    required this.rating,
    required this.reviewCount,
    required this.totalSales,
    required this.monthlyRevenueEst,
    required this.country,
    required this.openYear,
    required this.totalListings,
    this.activeListings = 0,
    this.inactiveListings = 0,
    this.totalOrders = 0,
    this.netPayout = 0.0,
    this.payoutCurrency = 'USD (\$)',
    required this.avgPrice,
    required this.topCategories,
    required this.topTags,
    required this.badges,
    this.isSaved = false,
    required this.opportunityScore,
    required this.description,
    this.ownerName = 'Verified Merchant',
    this.ownerAvatarUrl = '',
    this.listingDate = 'Oct 2021',
  });

  ShopModel copyWith({
    String? id,
    String? name,
    String? marketplace,
    String? url,
    String? logoUrl,
    double? rating,
    int? reviewCount,
    int? totalSales,
    double? monthlyRevenueEst,
    String? country,
    int? openYear,
    int? totalListings,
    int? activeListings,
    int? inactiveListings,
    int? totalOrders,
    double? netPayout,
    String? payoutCurrency,
    double? avgPrice,
    List<String>? topCategories,
    List<String>? topTags,
    List<String>? badges,
    bool? isSaved,
    int? opportunityScore,
    String? description,
    String? ownerName,
    String? ownerAvatarUrl,
    String? listingDate,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      marketplace: marketplace ?? this.marketplace,
      url: url ?? this.url,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalSales: totalSales ?? this.totalSales,
      monthlyRevenueEst: monthlyRevenueEst ?? this.monthlyRevenueEst,
      country: country ?? this.country,
      openYear: openYear ?? this.openYear,
      totalListings: totalListings ?? this.totalListings,
      activeListings: activeListings ?? (totalListings != null ? (totalListings * 0.9).round() : this.activeListings),
      inactiveListings: inactiveListings ?? (totalListings != null ? (totalListings * 0.1).round() : this.inactiveListings),
      totalOrders: totalOrders ?? (totalSales ?? this.totalOrders),
      netPayout: netPayout ?? this.netPayout,
      payoutCurrency: payoutCurrency ?? this.payoutCurrency,
      avgPrice: avgPrice ?? this.avgPrice,
      topCategories: topCategories ?? this.topCategories,
      topTags: topTags ?? this.topTags,
      badges: badges ?? this.badges,
      isSaved: isSaved ?? this.isSaved,
      opportunityScore: opportunityScore ?? this.opportunityScore,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      listingDate: listingDate ?? this.listingDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'marketplace': marketplace,
      'url': url,
      'logoUrl': logoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalSales': totalSales,
      'monthlyRevenueEst': monthlyRevenueEst,
      'country': country,
      'openYear': openYear,
      'totalListings': totalListings,
      'activeListings': activeListings,
      'inactiveListings': inactiveListings,
      'totalOrders': totalOrders,
      'netPayout': netPayout,
      'payoutCurrency': payoutCurrency,
      'avgPrice': avgPrice,
      'topCategories': topCategories,
      'topTags': topTags,
      'badges': badges,
      'isSaved': isSaved,
      'opportunityScore': opportunityScore,
      'description': description,
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'listingDate': listingDate,
    };
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    final tListings = json['totalListings'] as int? ?? 0;
    final tSales = json['totalSales'] as int? ?? 0;
    return ShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      marketplace: json['marketplace'] as String,
      url: json['url'] as String,
      logoUrl: json['logoUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['reviewCount'] as int? ?? 0,
      totalSales: tSales,
      monthlyRevenueEst: (json['monthlyRevenueEst'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String? ?? 'United States',
      openYear: json['openYear'] as int? ?? 2021,
      totalListings: tListings,
      activeListings: json['activeListings'] as int? ?? (tListings * 0.9).round(),
      inactiveListings: json['inactiveListings'] as int? ?? (tListings * 0.1).round(),
      totalOrders: json['totalOrders'] as int? ?? tSales,
      netPayout: (json['netPayout'] as num?)?.toDouble() ?? ((json['monthlyRevenueEst'] as num?)?.toDouble() ?? 0.0) * 0.88,
      payoutCurrency: json['payoutCurrency'] as String? ?? 'USD (\$)',
      avgPrice: (json['avgPrice'] as num).toDouble(),
      topCategories: List<String>.from(json['topCategories'] as List),
      topTags: List<String>.from(json['topTags'] as List),
      badges: List<String>.from(json['badges'] as List),
      isSaved: json['isSaved'] as bool? ?? false,
      opportunityScore: json['opportunityScore'] as int? ?? 75,
      description: json['description'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? 'Verified Merchant',
      ownerAvatarUrl: json['ownerAvatarUrl'] as String? ?? '',
      listingDate: json['listingDate'] as String? ?? 'Oct 2021',
    );
  }
}
