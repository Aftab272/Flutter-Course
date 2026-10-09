class TestModel {
  final String testId;
  final String visitId;
  final String name;
  final String date;
  final String? result;
  final String? doctorNotes;
  final String createdAt;
  final String updatedAt;

  TestModel({
    required this.testId,
    required this.visitId,
    required this.name,
    required this.date,
    this.result,
    this.doctorNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'test_id': testId,
      'visit_id': visitId,
      'name': name,
      'date': date,
      'result': result,
      'doctor_notes': doctorNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      testId: map['test_id'] ?? '',
      visitId: map['visit_id'] ?? '',
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      result: map['result'],
      doctorNotes: map['doctor_notes'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  TestModel copyWith({
    String? testId,
    String? visitId,
    String? name,
    String? date,
    String? result,
    String? doctorNotes,
    String? createdAt,
    String? updatedAt,
  }) {
    return TestModel(
      testId: testId ?? this.testId,
      visitId: visitId ?? this.visitId,
      name: name ?? this.name,
      date: date ?? this.date,
      result: result ?? this.result,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
