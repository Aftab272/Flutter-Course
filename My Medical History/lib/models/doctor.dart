import 'hospital.dart';

class Doctor {
  final String doctorId;
  final String userId;
  final String name;
  final String specialization;
  final String? phone;
  final String? photo;
  final String? hospitalId;
  final Hospital? hospital;
  final int visitCount;
  final String createdAt;
  final String updatedAt;

  Doctor({
    required this.doctorId,
    required this.userId,
    required this.name,
    required this.specialization,
    this.phone,
    this.photo,
    this.hospitalId,
    this.hospital,
    this.visitCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctor_id': doctorId,
      'user_id': userId,
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'photo': photo,
      'hospital_id': hospitalId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map, {Hospital? hospital, int visitCount = 0}) {
    return Doctor(
      doctorId: map['doctor_id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      phone: map['phone'],
      photo: map['photo'],
      hospitalId: map['hospital_id'],
      hospital: hospital,
      visitCount: visitCount,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Doctor copyWith({
    String? doctorId,
    String? userId,
    String? name,
    String? specialization,
    String? phone,
    String? photo,
    String? hospitalId,
    Hospital? hospital,
    int? visitCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return Doctor(
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      hospitalId: hospitalId ?? this.hospitalId,
      hospital: hospital ?? this.hospital,
      visitCount: visitCount ?? this.visitCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
