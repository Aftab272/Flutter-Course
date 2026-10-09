import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/visit.dart';
import '../models/medicine.dart';
import '../models/test_model.dart';
import '../models/attachment.dart';

class MedicalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- USER ---
  Future<User?> getUser(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', where: 'user_id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    final db = await _dbHelper.database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- HOSPITALS ---
  Future<List<Hospital>> getHospitals(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('hospitals', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((m) => Hospital.fromMap(m)).toList();
  }

  Future<void> saveHospital(Hospital hospital) async {
    final db = await _dbHelper.database;
    await db.insert('hospitals', hospital.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteHospital(String hospitalId) async {
    final db = await _dbHelper.database;
    await db.delete('hospitals', where: 'hospital_id = ?', whereArgs: [hospitalId]);
  }

  // --- DOCTORS ---
  Future<List<Doctor>> getDoctors(String userId) async {
    final db = await _dbHelper.database;
    final doctorMaps = await db.query('doctors', where: 'user_id = ?', whereArgs: [userId]);
    List<Doctor> doctors = [];

    for (var docMap in doctorMaps) {
      Hospital? hospital;
      if (docMap['hospital_id'] != null) {
        final hMaps = await db.query('hospitals', where: 'hospital_id = ?', whereArgs: [docMap['hospital_id']]);
        if (hMaps.isNotEmpty) {
          hospital = Hospital.fromMap(hMaps.first);
        }
      }

      // Count visits
      final visitMaps = await db.query('visits', where: 'doctor_id = ?', whereArgs: [docMap['doctor_id']]);
      doctors.add(Doctor.fromMap(docMap, hospital: hospital, visitCount: visitMaps.length));
    }
    return doctors;
  }

  Future<void> saveDoctor(Doctor doctor) async {
    final db = await _dbHelper.database;
    await db.insert('doctors', doctor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteDoctor(String doctorId) async {
    final db = await _dbHelper.database;
    await db.delete('doctors', where: 'doctor_id = ?', whereArgs: [doctorId]);
  }

  // --- VISITS ---
  Future<List<Visit>> getVisits(String userId) async {
    final db = await _dbHelper.database;
    final visitMaps = await db.query('visits', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
    List<Visit> visits = [];

    for (var vMap in visitMaps) {
      visits.add(await _enrichVisit(db, vMap));
    }
    return visits;
  }

  Future<List<Visit>> getVisitsByDoctor(String doctorId) async {
    final db = await _dbHelper.database;
    final visitMaps = await db.query('visits', where: 'doctor_id = ?', whereArgs: [doctorId], orderBy: 'date DESC');
    List<Visit> visits = [];

    for (var vMap in visitMaps) {
      visits.add(await _enrichVisit(db, vMap));
    }
    return visits;
  }

  Future<Visit> _enrichVisit(Database db, Map<String, dynamic> vMap) async {
    Doctor? doctor;
    final dMaps = await db.query('doctors', where: 'doctor_id = ?', whereArgs: [vMap['doctor_id']]);
    if (dMaps.isNotEmpty) {
      Hospital? hospital;
      if (dMaps.first['hospital_id'] != null) {
        final hMaps = await db.query('hospitals', where: 'hospital_id = ?', whereArgs: [dMaps.first['hospital_id']]);
        if (hMaps.isNotEmpty) hospital = Hospital.fromMap(hMaps.first);
      }
      doctor = Doctor.fromMap(dMaps.first, hospital: hospital);
    }

    Hospital? hospital;
    if (vMap['hospital_id'] != null) {
      final hMaps = await db.query('hospitals', where: 'hospital_id = ?', whereArgs: [vMap['hospital_id']]);
      if (hMaps.isNotEmpty) hospital = Hospital.fromMap(hMaps.first);
    }

    final medMaps = await db.query('medicines', where: 'visit_id = ?', whereArgs: [vMap['visit_id']]);
    final medicines = medMaps.map((m) => Medicine.fromMap(m)).toList();

    final testMaps = await db.query('tests', where: 'visit_id = ?', whereArgs: [vMap['visit_id']]);
    final tests = testMaps.map((t) => TestModel.fromMap(t)).toList();

    final attMaps = await db.query('attachments', where: 'visit_id = ?', whereArgs: [vMap['visit_id']]);
    final attachments = attMaps.map((a) => Attachment.fromMap(a)).toList();

    return Visit.fromMap(
      vMap,
      doctor: doctor,
      hospital: hospital,
      medicines: medicines,
      tests: tests,
      attachments: attachments,
    );
  }

  Future<void> saveVisit({
    required Visit visit,
    required List<Medicine> medicines,
    required List<TestModel> tests,
    required List<Attachment> attachments,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('visits', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete('medicines', where: 'visit_id = ?', whereArgs: [visit.visitId]);
      await txn.delete('tests', where: 'visit_id = ?', whereArgs: [visit.visitId]);
      await txn.delete('attachments', where: 'visit_id = ?', whereArgs: [visit.visitId]);

      for (var med in medicines) {
        await txn.insert('medicines', med.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var test in tests) {
        await txn.insert('tests', test.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var att in attachments) {
        await txn.insert('attachments', att.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> deleteVisit(String visitId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('medicines', where: 'visit_id = ?', whereArgs: [visitId]);
      await txn.delete('tests', where: 'visit_id = ?', whereArgs: [visitId]);
      await txn.delete('attachments', where: 'visit_id = ?', whereArgs: [visitId]);
      await txn.delete('visits', where: 'visit_id = ?', whereArgs: [visitId]);
    });
  }

  Future<List<Medicine>> getAllMedicines(String userId) async {
    final db = await _dbHelper.database;
    final visits = await getVisits(userId);
    final visitIds = visits.map((v) => v.visitId).toList();
    if (visitIds.isEmpty) return [];

    final placeholders = List.filled(visitIds.length, '?').join(',');
    final medMaps = await db.query('medicines', where: 'visit_id IN ($placeholders)', whereArgs: visitIds);
    return medMaps.map((m) => Medicine.fromMap(m)).toList();
  }

  Future<List<TestModel>> getAllTests(String userId) async {
    final db = await _dbHelper.database;
    final visits = await getVisits(userId);
    final visitIds = visits.map((v) => v.visitId).toList();
    if (visitIds.isEmpty) return [];

    final placeholders = List.filled(visitIds.length, '?').join(',');
    final testMaps = await db.query('tests', where: 'visit_id IN ($placeholders)', whereArgs: visitIds);
    return testMaps.map((t) => TestModel.fromMap(t)).toList();
  }

  Future<Map<String, int>> getStatistics(String userId) async {
    final doctors = await getDoctors(userId);
    final visits = await getVisits(userId);
    final medicines = await getAllMedicines(userId);
    final tests = await getAllTests(userId);

    return {
      'doctors': doctors.length,
      'visits': visits.length,
      'medicines': medicines.length,
      'reports': tests.length,
    };
  }
}
