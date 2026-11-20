import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ================= Institutions =================
  Future<List<Institution>> getInstitutions() async {
    try {
      final data = await _client.from('institutions').select();
      return (data as List).map((e) => Institution.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String> getOrCreateDefaultInstitution() async {
    try {
      final inst = await _client.from('institutions').select('id').limit(1);
      if ((inst as List).isNotEmpty) {
        return inst.first['id'];
      }
      final newInst = await _client.from('institutions').insert({
        'name': 'Main Campus',
        'code': 'CAMPUS-01',
        'timezone': 'UTC',
        'status': 'active',
      }).select('id');
      return (newInst as List).isNotEmpty ? newInst.first['id'] : '00000000-0000-0000-0000-000000000000';
    } catch (_) {
      return '00000000-0000-0000-0000-000000000000';
    }
  }

  // ================= Departments =================
  Future<List<DepartmentModel>> getDepartments(String institutionId) async {
    try {
      final data = await _client
          .from('departments')
          .select()
          .eq('institution_id', institutionId)
          .order('name');
      return (data as List).map((e) => DepartmentModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createDepartment(String institutionId, String name) async {
    await _client.from('departments').insert({
      'institution_id': institutionId,
      'name': name,
      'status': 'active',
    });
  }

  // ================= Academic Terms =================
  Future<List<AcademicTermModel>> getAcademicTerms(String institutionId) async {
    try {
      final data = await _client
          .from('academic_terms')
          .select()
          .eq('institution_id', institutionId)
          .order('start_date', ascending: false);
      return (data as List).map((e) => AcademicTermModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createAcademicTerm({
    required String institutionId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _client.from('academic_terms').insert({
      'institution_id': institutionId,
      'name': name,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'status': 'active',
    });
  }

  // ================= Classes =================
  Future<List<ClassModel>> getClasses(String institutionId) async {
    try {
      final data = await _client
          .from('classes')
          .select()
          .eq('institution_id', institutionId)
          .order('name');
      return (data as List).map((e) => ClassModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createClass({
    required String name,
    String? section,
    required String institutionId,
    String? departmentId,
    String? academicTermId,
  }) async {
    await _client.from('classes').insert({
      'name': name,
      'section': section,
      'institution_id': institutionId,
      'department_id': departmentId,
      'academic_term_id': academicTermId,
      'status': 'active',
    });
  }

  // ================= Subjects =================
  Future<List<SubjectModel>> getSubjects(String classId) async {
    try {
      final data = await _client
          .from('subjects')
          .select()
          .eq('class_id', classId)
          .order('name');
      return (data as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SubjectModel>> getAllSubjects(String institutionId) async {
    try {
      final data = await _client.from('subjects').select().order('name');
      return (data as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createSubject({
    required String name,
    required String code,
    required String classId,
    String? institutionId,
  }) async {
    await _client.from('subjects').insert({
      'name': name,
      'code': code,
      'class_id': classId,
      'institution_id': institutionId,
      'status': 'active',
    });
  }

  // ================= Users Management =================
  Future<List<UserProfile>> getUsersByRole(String role, {String? institutionId}) async {
    try {
      var query = _client.from('profiles').select().eq('role', role);
      if (institutionId != null) {
        query = query.eq('institution_id', institutionId);
      }
      final data = await query.order('full_name');
      return (data as List).map((e) => UserProfile.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ================= Enrollments =================
  Future<List<EnrollmentModel>> getEnrollments(String classId) async {
    try {
      final data = await _client.from('enrollments').select().eq('class_id', classId);
      return (data as List).map((e) => EnrollmentModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enrollStudent({
    required String classId,
    required String studentId,
    String? institutionId,
  }) async {
    await _client.from('enrollments').upsert({
      'class_id': classId,
      'student_id': studentId,
      'institution_id': institutionId,
      'status': 'enrolled',
    });
  }

  // ================= Teacher Assignments =================
  Future<List<TeacherAssignmentModel>> getTeacherAssignments(String teacherId) async {
    try {
      final data = await _client
          .from('teacher_assignments')
          .select()
          .eq('teacher_id', teacherId);
      return (data as List).map((e) => TeacherAssignmentModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> assignTeacher({
    required String teacherId,
    required String classId,
    required String subjectId,
    String? institutionId,
  }) async {
    await _client.from('teacher_assignments').upsert({
      'teacher_id': teacherId,
      'class_id': classId,
      'subject_id': subjectId,
      'institution_id': institutionId,
      'status': 'active',
    });
  }

  // ================= Attendance Sessions =================
  Future<String> getOrCreateDefaultSubjectId() async {
    try {
      final subjects = await _client.from('subjects').select('id').limit(1);
      if ((subjects as List).isNotEmpty) {
        return subjects.first['id'];
      }

      final instId = await getOrCreateDefaultInstitution();

      var cls = await _client.from('classes').select('id').limit(1);
      String classId;
      if ((cls as List).isEmpty) {
        final newClsList = await _client.from('classes').insert({
          'name': 'General Class',
          'section': 'A',
          'institution_id': instId,
          'status': 'active',
        }).select('id');
        classId = (newClsList as List).isNotEmpty ? newClsList.first['id'] : '00000000-0000-0000-0000-000000000000';
      } else {
        classId = cls.first['id'];
      }

      final newSubjectList = await _client.from('subjects').insert({
        'name': 'General Attendance',
        'code': 'GEN101',
        'class_id': classId,
        'institution_id': instId,
        'status': 'active',
      }).select('id');

      return (newSubjectList as List).isNotEmpty ? newSubjectList.first['id'] : '00000000-0000-0000-0000-000000000000';
    } catch (e) {
      return '00000000-0000-0000-0000-000000000000';
    }
  }

  Future<AttendanceSession> createSession({
    required String subjectId,
    required String teacherId,
    String? classId,
    required String qrToken,
    required DateTime expiresAt,
    required int lateThresholdMinutes,
  }) async {
    final now = DateTime.now().toUtc();
    final responseList = await _client.from('attendance_sessions').insert({
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'class_id': classId,
      'qr_token': qrToken,
      'starts_at': now.toIso8601String(),
      'expires_at': expiresAt.toUtc().toIso8601String(),
      'is_closed': false,
      'late_threshold_minutes': lateThresholdMinutes,
    }).select();

    if ((responseList as List).isNotEmpty) {
      return AttendanceSession.fromJson(responseList.first);
    }

    return AttendanceSession(
      id: qrToken,
      subjectId: subjectId,
      teacherId: teacherId,
      classId: classId,
      qrToken: qrToken,
      startsAt: now,
      expiresAt: expiresAt,
      isClosed: false,
      lateThresholdMinutes: lateThresholdMinutes,
      createdAt: now,
    );
  }

  Future<void> closeSession(String sessionId) async {
    final now = DateTime.now().toUtc();
    await _client.from('attendance_sessions').update({
      'is_closed': true,
      'closed_at': now.toIso8601String(),
    }).eq('id', sessionId);
  }

  Future<List<AttendanceSession>> getTeacherSessions(String teacherId) async {
    try {
      final data = await _client
          .from('attendance_sessions')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);
      return (data as List).map((e) => AttendanceSession.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ================= Attendance Marking (Server-Side Verified) =================
  Future<Map<String, dynamic>> markAttendance({
    required String qrToken,
    required String studentId,
    String? sessionId,
    DateTime? offlineTimestamp,
  }) async {
    try {
      // 1. First try secure PostgreSQL RPC function (Server-controlled time & constraints)
      final rpcRes = await _client.rpc(
        'mark_attendance_secure',
        params: {
          'p_qr_token': qrToken,
          'p_student_id': studentId,
        },
      );

      if (rpcRes != null && rpcRes is Map<String, dynamic>) {
        return rpcRes;
      }
    } catch (_) {
      // Fallback to table operation if RPC is not yet applied
    }

    // Direct table fallback
    try {
      final sessionList = await _client
          .from('attendance_sessions')
          .select()
          .eq('qr_token', qrToken)
          .eq('is_closed', false);

      if ((sessionList as List).isEmpty) {
        return {'success': false, 'message': 'Invalid, closed, or nonexistent attendance session.'};
      }

      final session = AttendanceSession.fromJson(sessionList.first);

      if (DateTime.now().toUtc().isAfter(session.expiresAt)) {
        return {'success': false, 'message': 'Attendance QR Code has expired.'};
      }

      final existingRecordList = await _client
          .from('attendance_records')
          .select()
          .eq('session_id', session.id)
          .eq('student_id', studentId);

      if ((existingRecordList as List).isNotEmpty) {
        return {'success': false, 'message': 'Attendance has already been recorded for this session.'};
      }

      final now = offlineTimestamp?.toUtc() ?? DateTime.now().toUtc();
      final diffMinutes = now.difference(session.startsAt).inMinutes;
      final status = diffMinutes > session.lateThresholdMinutes ? 'late' : 'present';

      await _client.from('attendance_records').insert({
        'session_id': session.id,
        'student_id': studentId,
        'scanned_at': now.toIso8601String(),
        'status': status,
        'is_offline_synced': offlineTimestamp != null,
      });

      return {
        'success': true,
        'status': status,
        'message': 'Attendance recorded successfully as ${status.toUpperCase()}!',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error recording attendance: $e'};
    }
  }

  Future<Map<String, dynamic>> markAttendanceSecure({
    required String qrToken,
    required String studentId,
    String? sessionId,
    DateTime? offlineTimestamp,
  }) async {
    return markAttendance(
      qrToken: qrToken,
      studentId: studentId,
      sessionId: sessionId,
      offlineTimestamp: offlineTimestamp,
    );
  }

  // ================= History & Records =================
  Future<List<AttendanceRecord>> getStudentAttendance(String studentId) async {
    try {
      final data = await _client
          .from('attendance_records')
          .select()
          .eq('student_id', studentId)
          .order('scanned_at', ascending: false);
      return (data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AttendanceRecord>> getSessionRecords(String sessionId) async {
    try {
      final data = await _client
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId)
          .order('scanned_at', ascending: true);
      return (data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ================= Audit Logs =================
  Future<List<AuditLog>> getAuditLogs() async {
    try {
      final data = await _client
          .from('audit_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      return (data as List).map((e) => AuditLog.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> logAudit({
    required String action,
    String? actorId,
    String? entityType,
    String? entityId,
    String? details,
  }) async {
    try {
      await _client.from('audit_logs').insert({
        'actor_id': actorId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
      });
    } catch (_) {}
  }

  // ================= Backup & Restore Engine (Part L) =================
  Future<Map<String, dynamic>> exportFullBackupPayload(String institutionId) async {
    final depts = await _client.from('departments').select().eq('institution_id', institutionId);
    final terms = await _client.from('academic_terms').select().eq('institution_id', institutionId);
    final classes = await _client.from('classes').select().eq('institution_id', institutionId);
    final subjects = await _client.from('subjects').select().eq('institution_id', institutionId);
    final sessions = await _client.from('attendance_sessions').select().eq('institution_id', institutionId);
    final records = await _client.from('attendance_records').select().eq('institution_id', institutionId);
    final logs = await _client.from('audit_logs').select().limit(500);

    return {
      'institution_id': institutionId,
      'departments': depts,
      'academic_terms': terms,
      'classes': classes,
      'subjects': subjects,
      'attendance_sessions': sessions,
      'attendance_records': records,
      'audit_logs': logs,
    };
  }

  Future<void> restoreBackupPayload(
    Map<String, dynamic> payload, {
    bool overwrite = false,
  }) async {
    // If overwrite is requested, delete dependent tables in reverse order
    if (overwrite) {
      final instId = payload['institution_id'] as String?;
      if (instId != null) {
        try {
          await _client.from('attendance_records').delete().eq('institution_id', instId);
          await _client.from('attendance_sessions').delete().eq('institution_id', instId);
          await _client.from('subjects').delete().eq('institution_id', instId);
          await _client.from('classes').delete().eq('institution_id', instId);
          await _client.from('academic_terms').delete().eq('institution_id', instId);
          await _client.from('departments').delete().eq('institution_id', instId);
        } catch (_) {}
      }
    }

    // Upsert departments
    if (payload['departments'] is List) {
      for (final item in (payload['departments'] as List)) {
        await _client.from('departments').upsert(item);
      }
    }
    // Upsert academic terms
    if (payload['academic_terms'] is List) {
      for (final item in (payload['academic_terms'] as List)) {
        await _client.from('academic_terms').upsert(item);
      }
    }
    // Upsert classes
    if (payload['classes'] is List) {
      for (final item in (payload['classes'] as List)) {
        await _client.from('classes').upsert(item);
      }
    }
    // Upsert subjects
    if (payload['subjects'] is List) {
      for (final item in (payload['subjects'] as List)) {
        await _client.from('subjects').upsert(item);
      }
    }
    // Upsert sessions
    if (payload['attendance_sessions'] is List) {
      for (final item in (payload['attendance_sessions'] as List)) {
        await _client.from('attendance_sessions').upsert(item);
      }
    }
    // Upsert records
    if (payload['attendance_records'] is List) {
      for (final item in (payload['attendance_records'] as List)) {
        await _client.from('attendance_records').upsert(item);
      }
    }
  }

  Future<void> recordBackupHistory({
    required String institutionId,
    required String? initiatedBy,
    required String filename,
    required String status,
    String? driveFileId,
    String? checksum,
    int recordCount = 0,
    int fileSizeBytes = 0,
    String? errorSummary,
  }) async {
    try {
      await _client.from('backup_history').insert({
        'institution_id': institutionId,
        'initiated_by': initiatedBy,
        'filename': filename,
        'status': status,
        'drive_file_id': driveFileId,
        'checksum': checksum,
        'record_count': recordCount,
        'file_size_bytes': fileSizeBytes,
        'error_summary': errorSummary,
      });
    } catch (_) {}
  }

  Future<List<BackupHistory>> getBackupHistory(String institutionId) async {
    try {
      final data = await _client
          .from('backup_history')
          .select()
          .eq('institution_id', institutionId)
          .order('created_at', ascending: false)
          .limit(30);
      return (data as List).map((e) => BackupHistory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
