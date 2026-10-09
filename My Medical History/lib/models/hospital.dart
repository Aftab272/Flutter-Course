class Hospital {
  final String hospitalId;
  final String userId;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? photo;
  final String createdAt;
  final String updatedAt;

  Hospital({
    required this.hospitalId,
    required this.userId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'hospital_id': hospitalId,
      'user_id': userId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photo': photo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      hospitalId: map['hospital_id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      photo: map['photo'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Hospital copyWith({
    String? hospitalId,
    String? userId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? photo,
    String? createdAt,
    String? updatedAt,
  }) {
    return Hospital(
      hospitalId: hospitalId ?? this.hospitalId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
