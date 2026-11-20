class CityLocation {
  final int? id;
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final bool isFavourite;
  final DateTime createdAt;

  CityLocation({
    this.id,
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isFavourite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'isFavourite': isFavourite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CityLocation.fromMap(Map<String, dynamic> map) {
    return CityLocation(
      id: map['id'] as int?,
      cityName: map['cityName'] ?? '',
      country: map['country'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isFavourite: (map['isFavourite'] as int?) == 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  CityLocation copyWith({
    int? id,
    String? cityName,
    String? country,
    double? latitude,
    double? longitude,
    bool? isFavourite,
    DateTime? createdAt,
  }) {
    return CityLocation(
      id: id ?? this.id,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavourite: isFavourite ?? this.isFavourite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RecentSearch {
  final int? id;
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime searchedAt;

  RecentSearch({
    this.id,
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    DateTime? searchedAt,
  }) : searchedAt = searchedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory RecentSearch.fromMap(Map<String, dynamic> map) {
    return RecentSearch(
      id: map['id'] as int?,
      cityName: map['cityName'] ?? '',
      country: map['country'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      searchedAt: map['searchedAt'] != null ? DateTime.parse(map['searchedAt']) : DateTime.now(),
    );
  }
}
