class ResearchReportModel {
  final String id;
  final String title;
  final String marketplace;
  final String type; // 'Shop Analysis', 'Product Opportunity', 'Competitor Comparison'
  final DateTime timestamp;
  final double avgPrice;
  final int opportunityScore;
  final String saturationLevel;
  final String summary;
  final List<String> keyOpportunities;
  final String marketRisk;

  const ResearchReportModel({
    required this.id,
    required this.title,
    required this.marketplace,
    required this.type,
    required this.timestamp,
    required this.avgPrice,
    required this.opportunityScore,
    required this.saturationLevel,
    required this.summary,
    required this.keyOpportunities,
    required this.marketRisk,
  });
}

class PlatformStatModel {
  final String marketplace;
  final int analyzedCount;
  final double averageRating;
  final double totalRevenueAnalyzed;
  final String topCategory;
  final double growthRate;

  const PlatformStatModel({
    required this.marketplace,
    required this.analyzedCount,
    required this.averageRating,
    required this.totalRevenueAnalyzed,
    required this.topCategory,
    required this.growthRate,
  });
}

