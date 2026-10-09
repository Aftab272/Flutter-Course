class Medicine {
  final String medicineId;
  final String visitId;
  final String name;
  final String dose;
  final String frequency;
  final String duration;
  final String? mealInstruction;
  final String? instructions;
  final String createdAt;
  final String updatedAt;

  Medicine({
    required this.medicineId,
    required this.visitId,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.duration,
    this.mealInstruction,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_id': medicineId,
      'visit_id': visitId,
      'name': name,
      'dose': dose,
      'frequency': frequency,
      'duration': duration,
      'meal_instruction': mealInstruction,
      'instructions': instructions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      medicineId: map['medicine_id'] ?? '',
      visitId: map['visit_id'] ?? '',
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      mealInstruction: map['meal_instruction'],
      instructions: map['instructions'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Medicine copyWith({
    String? medicineId,
    String? visitId,
    String? name,
    String? dose,
    String? frequency,
    String? duration,
    String? mealInstruction,
    String? instructions,
    String? createdAt,
    String? updatedAt,
  }) {
    return Medicine(
      medicineId: medicineId ?? this.medicineId,
      visitId: visitId ?? this.visitId,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      mealInstruction: mealInstruction ?? this.mealInstruction,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
