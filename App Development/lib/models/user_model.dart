class UserModel {
  final String id;
  final String name;
  final String email;
  final String plan;
  final String avatarUrl;
  final int shopsAnalyzedCount;
  final int maxShopsQuota;
  final int productsResearchedCount;
  final int maxProductsQuota;
  final String apiEndpoint;
  final String apiKey;
  final String currency;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.avatarUrl,
    required this.shopsAnalyzedCount,
    required this.maxShopsQuota,
    required this.productsResearchedCount,
    required this.maxProductsQuota,
    required this.apiEndpoint,
    required this.apiKey,
    this.currency = 'USD (\$)',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? plan,
    String? avatarUrl,
    int? shopsAnalyzedCount,
    int? maxShopsQuota,
    int? productsResearchedCount,
    int? maxProductsQuota,
    String? apiEndpoint,
    String? apiKey,
    String? currency,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      shopsAnalyzedCount: shopsAnalyzedCount ?? this.shopsAnalyzedCount,
      maxShopsQuota: maxShopsQuota ?? this.maxShopsQuota,
      productsResearchedCount: productsResearchedCount ?? this.productsResearchedCount,
      maxProductsQuota: maxProductsQuota ?? this.maxProductsQuota,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      apiKey: apiKey ?? this.apiKey,
      currency: currency ?? this.currency,
    );
  }
}

