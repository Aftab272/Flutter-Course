class Attachment {
  final String attachmentId;
  final String visitId;
  final String type; // Prescription, Medical Report, Hospital Photo, Doctor Photo, Other
  final String fileName;
  final String localPath;
  final String? driveFileId;
  final String? mimeType;
  final String createdAt;
  final String updatedAt;

  Attachment({
    required this.attachmentId,
    required this.visitId,
    required this.type,
    required this.fileName,
    required this.localPath,
    this.driveFileId,
    this.mimeType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'attachment_id': attachmentId,
      'visit_id': visitId,
      'type': type,
      'file_name': fileName,
      'local_path': localPath,
      'drive_file_id': driveFileId,
      'mime_type': mimeType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      attachmentId: map['attachment_id'] ?? '',
      visitId: map['visit_id'] ?? '',
      type: map['type'] ?? '',
      fileName: map['file_name'] ?? '',
      localPath: map['local_path'] ?? '',
      driveFileId: map['drive_file_id'],
      mimeType: map['mime_type'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Attachment copyWith({
    String? attachmentId,
    String? visitId,
    String? type,
    String? fileName,
    String? localPath,
    String? driveFileId,
    String? mimeType,
    String? createdAt,
    String? updatedAt,
  }) {
    return Attachment(
      attachmentId: attachmentId ?? this.attachmentId,
      visitId: visitId ?? this.visitId,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      driveFileId: driveFileId ?? this.driveFileId,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
