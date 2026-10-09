import 'doctor.dart';
import 'hospital.dart';
import 'medicine.dart';
import 'test_model.dart';
import 'attachment.dart';

class Visit {
  final String visitId;
  final String userId;
  final String doctorId;
  final String? hospitalId;
  final String date;
  final String time;
  final String? reason;
  final String? symptoms;
  final String? diagnosis;
  final String? notes;
  final String? followUp;
  final Doctor? doctor;
  final Hospital? hospital;
  final List<Medicine> medicines;
  final List<TestModel> tests;
  final List<Attachment> attachments;
  final String createdAt;
  final String updatedAt;

  Visit({
    required this.visitId,
    required this.userId,
    required this.doctorId,
    this.hospitalId,
    required this.date,
    required this.time,
    this.reason,
    this.symptoms,
    this.diagnosis,
    this.notes,
    this.followUp,
    this.doctor,
    this.hospital,
    this.medicines = const [],
    this.tests = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'visit_id': visitId,
      'user_id': userId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'date': date,
      'time': time,
      'reason': reason,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'notes': notes,
      'follow_up': followUp,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Visit.fromMap(
    Map<String, dynamic> map, {
    Doctor? doctor,
    Hospital? hospital,
    List<Medicine> medicines = const [],
    List<TestModel> tests = const [],
    List<Attachment> attachments = const [],
  }) {
    return Visit(
      visitId: map['visit_id'] ?? '',
      userId: map['user_id'] ?? '',
      doctorId: map['doctor_id'] ?? '',
      hospitalId: map['hospital_id'],
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      reason: map['reason'],
      symptoms: map['symptoms'],
      diagnosis: map['diagnosis'],
      notes: map['notes'],
      followUp: map['follow_up'],
      doctor: doctor,
      hospital: hospital,
      medicines: medicines,
      tests: tests,
      attachments: attachments,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Visit copyWith({
    String? visitId,
    String? userId,
    String? doctorId,
    String? hospitalId,
    String? date,
    String? time,
    String? reason,
    String? symptoms,
    String? diagnosis,
    String? notes,
    String? followUp,
    Doctor? doctor,
    Hospital? hospital,
    List<Medicine>? medicines,
    List<TestModel>? tests,
    List<Attachment>? attachments,
    String? createdAt,
    String? updatedAt,
  }) {
    return Visit(
      visitId: visitId ?? this.visitId,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      hospitalId: hospitalId ?? this.hospitalId,
      date: date ?? this.date,
      time: time ?? this.time,
      reason: reason ?? this.reason,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      followUp: followUp ?? this.followUp,
      doctor: doctor ?? this.doctor,
      hospital: hospital ?? this.hospital,
      medicines: medicines ?? this.medicines,
      tests: tests ?? this.tests,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
