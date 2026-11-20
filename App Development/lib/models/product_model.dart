class ProductModel {
  final String id;
  final String shopId;
  final String shopName;
  final String marketplace; // 'Etsy', 'Amazon', 'eBay', 'Shopify'
  final String title;
  final double price;
  final double? originalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final int salesEstimate;
  final double monthlyRevenue;
  final int opportunityScore; // 1 - 100
  final String saturationLevel; // 'Low', 'Medium', 'High'
  final double competitionScore; // 1.0 - 5.0
  final String category;
  final List<String> tags;
  final String description;
  final List<String> imageUrls;
  final String stockStatus;
  final bool isSaved;
  final DateTime createdAt;
  final String ownerName;
  final String ownerAvatarUrl;
  final String? videoUrl;
  final List<String> mockupUrls;
  final String? originalUrl;
  final List<Map<String, dynamic>> crossPlatformListings;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.marketplace,
    required this.title,
    required this.price,
    this.originalPrice,
    this.currency = '\$',
    required this.rating,
    required this.reviewCount,
    required this.salesEstimate,
    required this.monthlyRevenue,
    required this.opportunityScore,
    required this.saturationLevel,
    required this.competitionScore,
    required this.category,
    required this.tags,
    required this.description,
    required this.imageUrls,
    this.stockStatus = 'In Stock',
    this.isSaved = false,
    required this.createdAt,
    this.ownerName = 'Verified Merchant',
    this.ownerAvatarUrl = '',
    this.videoUrl,
    this.mockupUrls = const [],
    this.originalUrl,
    this.crossPlatformListings = const [],
  });

  ProductModel copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? marketplace,
    String? title,
    double? price,
    double? originalPrice,
    String? currency,
    double? rating,
    int? reviewCount,
    int? salesEstimate,
    double? monthlyRevenue,
    int? opportunityScore,
    String? saturationLevel,
    double? competitionScore,
    String? category,
    List<String>? tags,
    String? description,
    List<String>? imageUrls,
    String? stockStatus,
    bool? isSaved,
    DateTime? createdAt,
    String? ownerName,
    String? ownerAvatarUrl,
    String? videoUrl,
    List<String>? mockupUrls,
    String? originalUrl,
    List<Map<String, dynamic>>? crossPlatformListings,
  }) {
    return ProductModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      marketplace: marketplace ?? this.marketplace,
      title: title ?? this.title,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      salesEstimate: salesEstimate ?? this.salesEstimate,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      opportunityScore: opportunityScore ?? this.opportunityScore,
      saturationLevel: saturationLevel ?? this.saturationLevel,
      competitionScore: competitionScore ?? this.competitionScore,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      stockStatus: stockStatus ?? this.stockStatus,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      mockupUrls: mockupUrls ?? this.mockupUrls,
      originalUrl: originalUrl ?? this.originalUrl,
      crossPlatformListings: crossPlatformListings ?? this.crossPlatformListings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'marketplace': marketplace,
      'title': title,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'salesEstimate': salesEstimate,
      'monthlyRevenue': monthlyRevenue,
      'opportunityScore': opportunityScore,
      'saturationLevel': saturationLevel,
      'competitionScore': competitionScore,
      'category': category,
      'tags': tags,
      'description': description,
      'imageUrls': imageUrls,
      'stockStatus': stockStatus,
      'isSaved': isSaved,
      'createdAt': createdAt.toIso8601String(),
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'videoUrl': videoUrl,
      'mockupUrls': mockupUrls,
      'originalUrl': originalUrl,
      'crossPlatformListings': crossPlatformListings,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      marketplace: json['marketplace'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? '\$',
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      salesEstimate: json['salesEstimate'] as int,
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      opportunityScore: json['opportunityScore'] as int,
      saturationLevel: json['saturationLevel'] as String,
      competitionScore: (json['competitionScore'] as num).toDouble(),
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      stockStatus: json['stockStatus'] as String? ?? 'In Stock',
      isSaved: json['isSaved'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownerName: json['ownerName'] as String? ?? 'Verified Merchant',
      ownerAvatarUrl: json['ownerAvatarUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      mockupUrls: json['mockupUrls'] != null ? List<String>.from(json['mockupUrls'] as List) : const [],
      originalUrl: json['originalUrl'] as String?,
      crossPlatformListings: json['crossPlatformListings'] != null
          ? List<Map<String, dynamic>>.from(json['crossPlatformListings'] as List)
          : const [],
    );
  }
}
