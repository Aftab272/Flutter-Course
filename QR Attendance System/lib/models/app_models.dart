enum UserRole { admin, teacher, student }

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? studentIdNumber;
  final String? institutionId;
  final String status;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.studentIdNumber,
    this.institutionId,
    this.status = 'active',
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole;
    switch (json['role']) {
      case 'admin':
        parsedRole = UserRole.admin;
        break;
      case 'teacher':
        parsedRole = UserRole.teacher;
        break;
      default:
        parsedRole = UserRole.student;
    }
    return UserProfile(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: parsedRole,
      studentIdNumber: json['student_id_number'],
      institutionId: json['institution_id'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role.name,
        'student_id_number': studentIdNumber,
        'institution_id': institutionId,
        'status': status,
      };
}

class Institution {
  final String id;
  final String name;
  final String code;
  final String timezone;
  final String status;

  Institution({
    required this.id,
    required this.name,
    required this.code,
    this.timezone = 'UTC',
    this.status = 'active',
  });

  factory Institution.fromJson(Map<String, dynamic> json) => Institution(
        id: json['id'],
        name: json['name'],
        code: json['code'] ?? '',
        timezone: json['timezone'] ?? 'UTC',
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'timezone': timezone,
        'status': status,
      };
}

class DepartmentModel {
  final String id;
  final String institutionId;
  final String name;
  final String status;

  DepartmentModel({
    required this.id,
    required this.institutionId,
    required this.name,
    this.status = 'active',
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) => DepartmentModel(
        id: json['id'],
        institutionId: json['institution_id'] ?? '',
        name: json['name'] ?? '',
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution_id': institutionId,
        'name': name,
        'status': status,
      };
}

class AcademicTermModel {
  final String id;
  final String institutionId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  AcademicTermModel({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
  });

  factory AcademicTermModel.fromJson(Map<String, dynamic> json) => AcademicTermModel(
        id: json['id'],
        institutionId: json['institution_id'] ?? '',
        name: json['name'] ?? '',
        startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution_id': institutionId,
        'name': name,
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate.toIso8601String().substring(0, 10),
        'status': status,
      };
}

class ClassModel {
  final String id;
  final String name;
  final String? section;
  final String institutionId;
  final String? departmentId;
  final String? academicTermId;
  final String status;

  ClassModel({
    required this.id,
    required this.name,
    this.section,
    required this.institutionId,
    this.departmentId,
    this.academicTermId,
    this.status = 'active',
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        id: json['id'],
        name: json['name'] ?? '',
        section: json['section'],
        institutionId: json['institution_id'] ?? '',
        departmentId: json['department_id'],
        academicTermId: json['academic_term_id'],
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'section': section,
        'institution_id': institutionId,
        'department_id': departmentId,
        'academic_term_id': academicTermId,
        'status': status,
      };
}

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String classId;
  final String? institutionId;
  final String status;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.classId,
    this.institutionId,
    this.status = 'active',
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'],
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        classId: json['class_id'] ?? '',
        institutionId: json['institution_id'],
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'class_id': classId,
        'institution_id': institutionId,
        'status': status,
      };
}

class EnrollmentModel {
  final String id;
  final String classId;
  final String studentId;
  final String status;
  final DateTime enrolledAt;

  EnrollmentModel({
    required this.id,
    required this.classId,
    required this.studentId,
    this.status = 'enrolled',
    required this.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
        id: json['id'],
        classId: json['class_id'] ?? '',
        studentId: json['student_id'] ?? '',
        status: json['status'] ?? 'enrolled',
        enrolledAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'student_id': studentId,
        'status': status,
        'created_at': enrolledAt.toIso8601String(),
      };
}

class TeacherAssignmentModel {
  final String id;
  final String teacherId;
  final String subjectId;
  final String classId;
  final String status;

  TeacherAssignmentModel({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    this.status = 'active',
  });

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) => TeacherAssignmentModel(
        id: json['id'],
        teacherId: json['teacher_id'] ?? '',
        subjectId: json['subject_id'] ?? '',
        classId: json['class_id'] ?? '',
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacher_id': teacherId,
        'subject_id': subjectId,
        'class_id': classId,
        'status': status,
      };
}

class AttendanceSession {
  final String id;
  final String subjectId;
  final String teacherId;
  final String? classId;
  final String qrToken;
  final DateTime startsAt;
  final DateTime expiresAt;
  final DateTime? closedAt;
  final bool isClosed;
  final int lateThresholdMinutes;
  final DateTime createdAt;

  AttendanceSession({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    this.classId,
    required this.qrToken,
    required this.startsAt,
    required this.expiresAt,
    this.closedAt,
    required this.isClosed,
    required this.lateThresholdMinutes,
    required this.createdAt,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) => AttendanceSession(
        id: json['id'],
        subjectId: json['subject_id'] ?? '',
        teacherId: json['teacher_id'] ?? '',
        classId: json['class_id'],
        qrToken: json['qr_token'] ?? '',
        startsAt: json['starts_at'] != null ? DateTime.parse(json['starts_at']) : DateTime.parse(json['created_at']),
        expiresAt: DateTime.parse(json['expires_at']),
        closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at']) : null,
        isClosed: json['is_closed'] ?? false,
        lateThresholdMinutes: json['late_threshold_minutes'] ?? 10,
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'teacher_id': teacherId,
        'class_id': classId,
        'qr_token': qrToken,
        'starts_at': startsAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'closed_at': closedAt?.toIso8601String(),
        'is_closed': isClosed,
        'late_threshold_minutes': lateThresholdMinutes,
        'created_at': createdAt.toIso8601String(),
      };
}

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime scannedAt;
  final String status; // 'present', 'late', 'absent'
  final bool isOfflineSynced;
  final String? correctionReason;
  final String? correctedBy;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.scannedAt,
    required this.status,
    required this.isOfflineSynced,
    this.correctionReason,
    this.correctedBy,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        id: json['id'],
        sessionId: json['session_id'] ?? '',
        studentId: json['student_id'] ?? '',
        scannedAt: DateTime.parse(json['scanned_at']),
        status: json['status'] ?? 'present',
        isOfflineSynced: json['is_offline_synced'] ?? true,
        correctionReason: json['correction_reason'],
        correctedBy: json['corrected_by'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'student_id': studentId,
        'scanned_at': scannedAt.toIso8601String(),
        'status': status,
        'is_offline_synced': isOfflineSynced,
        'correction_reason': correctionReason,
        'corrected_by': correctedBy,
      };
}

class BackupHistoryModel {
  final String id;
  final String? institutionId;
  final String? initiatedBy;
  final String? driveFileId;
  final String filename;
  final String status;
  final String schemaVersion;
  final String? checksum;
  final int recordCount;
  final int fileSizeBytes;
  final String? errorSummary;
  final DateTime createdAt;

  BackupHistoryModel({
    required this.id,
    this.institutionId,
    this.initiatedBy,
    this.driveFileId,
    required this.filename,
    required this.status,
    this.schemaVersion = '1.0',
    this.checksum,
    this.recordCount = 0,
    this.fileSizeBytes = 0,
    this.errorSummary,
    required this.createdAt,
  });

  factory BackupHistoryModel.fromJson(Map<String, dynamic> json) => BackupHistoryModel(
        id: json['id'] ?? '',
        institutionId: json['institution_id'],
        initiatedBy: json['initiated_by'],
        driveFileId: json['drive_file_id'],
        filename: json['filename'] ?? '',
        status: json['status'] ?? 'completed',
        schemaVersion: json['schema_version'] ?? '1.0',
        checksum: json['checksum'],
        recordCount: json['record_count'] ?? 0,
        fileSizeBytes: json['file_size_bytes'] ?? 0,
        errorSummary: json['error_summary'],
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution_id': institutionId,
        'initiated_by': initiatedBy,
        'drive_file_id': driveFileId,
        'filename': filename,
        'status': status,
        'schema_version': schemaVersion,
        'checksum': checksum,
        'record_count': recordCount,
        'file_size_bytes': fileSizeBytes,
        'error_summary': errorSummary,
        'created_at': createdAt.toIso8601String(),
      };
}

typedef BackupHistory = BackupHistoryModel;

class NotificationModel {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'],
        recipientId: json['recipient_id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
        createdAt: DateTime.parse(json['created_at']),
      );
}

class AuditLog {
  final String id;
  final String? actorId;
  final String action;
  final String? entityType;
  final String? entityId;
  final String? details;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    this.actorId,
    required this.action,
    this.entityType,
    this.entityId,
    this.details,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'],
        actorId: json['actor_id'] ?? json['user_id'],
        action: json['action'] ?? '',
        entityType: json['entity_type'],
        entityId: json['entity_id'],
        details: json['details'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
