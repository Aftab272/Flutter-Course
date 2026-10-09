class User {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String createdAt;
  final String updatedAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'photo': photo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  User copyWith({
    String? userId,
    String? name,
    String? email,
    String? photo,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
