import 'product_model.dart';

class RelatedKeyword {
  final String keyword;
  final int searchVolume;
  final int competition;
  final int opportunityScore;
  final double avgPrice;
  final String trend; // 'up', 'stable', 'hot'
  final int growthPercent;
  final bool isLongTail;

  const RelatedKeyword({
    required this.keyword,
    required this.searchVolume,
    required this.competition,
    required this.opportunityScore,
    required this.avgPrice,
    this.trend = 'up',
    this.growthPercent = 15,
    this.isLongTail = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'keyword': keyword,
      'searchVolume': searchVolume,
      'competition': competition,
      'opportunityScore': opportunityScore,
      'avgPrice': avgPrice,
      'trend': trend,
      'growthPercent': growthPercent,
      'isLongTail': isLongTail,
    };
  }
}

class KeywordIntelligence {
  final String keyword;
  final String marketplace;
  final int searchVolume;
  final int competitionListings;
  final int opportunityScore; // 1-100 (Higher is better)
  final int difficultyScore; // 1-100 (Lower is easier to rank)
  final String difficultyLabel; // 'Low', 'Medium', 'High', 'Super Competitive'
  final double avgPrice;
  final int estMonthlySales;
  final double estMonthlyRevenue;
  final double ctr; // Click-through rate
  final String trend; // 'trending_up', 'stable', 'seasonal', 'hot'
  final int trendGrowthPercent;
  final List<RelatedKeyword> relatedKeywords;
  final List<String> recommendedTags;
  final List<ProductModel> topProducts;
  final DateTime analyzedAt;

  List<String> get listingTags => recommendedTags;

  KeywordIntelligence({
    required this.keyword,
    this.marketplace = 'All Marketplaces',
    required this.searchVolume,
    required this.competitionListings,
    required this.opportunityScore,
    required this.difficultyScore,
    required this.difficultyLabel,
    required this.avgPrice,
    required this.estMonthlySales,
    required this.estMonthlyRevenue,
    required this.ctr,
    this.trend = 'trending_up',
    this.trendGrowthPercent = 24,
    required this.relatedKeywords,
    required this.recommendedTags,
    required this.topProducts,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();
}

