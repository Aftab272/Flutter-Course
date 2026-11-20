class CompetitorModel {
  final String id;
  final String name;
  final String marketplace;
  final String url;
  final double rating;
  final int salesCount;
  final double priceAdvantage; // e.g. -12.5 means 12.5% cheaper, +10.0 means 10% more expensive
  final double monthlyRevenueEst;
  final int overlapPercentage; // Product category catalog overlap
  final String strengthSummary;
  final List<String> weakPoints;
  final List<String> topCategories;
  final int productCount;

  const CompetitorModel({
    required this.id,
    required this.name,
    required this.marketplace,
    required this.url,
    required this.rating,
    required this.salesCount,
    required this.priceAdvantage,
    required this.monthlyRevenueEst,
    required this.overlapPercentage,
    required this.strengthSummary,
    required this.weakPoints,
    required this.topCategories,
    required this.productCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'marketplace': marketplace,
      'url': url,
      'rating': rating,
      'salesCount': salesCount,
      'priceAdvantage': priceAdvantage,
      'monthlyRevenueEst': monthlyRevenueEst,
      'overlapPercentage': overlapPercentage,
      'strengthSummary': strengthSummary,
      'weakPoints': weakPoints,
      'topCategories': topCategories,
      'productCount': productCount,
    };
  }

  factory CompetitorModel.fromJson(Map<String, dynamic> json) {
    return CompetitorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      marketplace: json['marketplace'] as String,
      url: json['url'] as String,
      rating: (json['rating'] as num).toDouble(),
      salesCount: json['salesCount'] as int,
      priceAdvantage: (json['priceAdvantage'] as num).toDouble(),
      monthlyRevenueEst: (json['monthlyRevenueEst'] as num).toDouble(),
      overlapPercentage: json['overlapPercentage'] as int,
      strengthSummary: json['strengthSummary'] as String,
      weakPoints: List<String>.from(json['weakPoints'] as List),
      topCategories: List<String>.from(json['topCategories'] as List),
      productCount: json['productCount'] as int,
    );
  }
}

