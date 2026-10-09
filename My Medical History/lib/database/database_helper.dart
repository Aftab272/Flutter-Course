import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medical_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        photo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE hospitals (
        hospital_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        photo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        doctor_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        phone TEXT,
        photo TEXT,
        hospital_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE visits (
        visit_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        hospital_id TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        reason TEXT,
        symptoms TEXT,
        diagnosis TEXT,
        notes TEXT,
        follow_up TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (doctor_id) REFERENCES doctors (doctor_id) ON DELETE CASCADE,
        FOREIGN KEY (hospital_id) REFERENCES hospitals (hospital_id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE medicines (
        medicine_id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dose TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration TEXT NOT NULL,
        meal_instruction TEXT,
        instructions TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES visits (visit_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tests (
        test_id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        result TEXT,
        doctor_notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES visits (visit_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attachments (
        attachment_id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        type TEXT NOT NULL,
        file_name TEXT NOT NULL,
        local_path TEXT NOT NULL,
        drive_file_id TEXT,
        mime_type TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES visits (visit_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_logs (
        sync_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        last_sync TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        error_message TEXT
      )
    ''');

    // Insert sample seed data
    await _seedData(db);
  }

  Future _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    const userId = 'sample_user_1';
    const hospitalId = 'hospital_city_medical';
    const doctorId = 'doctor_ahmed_khan';

    // Seed User
    await db.insert('users', {
      'user_id': userId,
      'name': 'John Doe',
      'email': 'john.doe@gmail.com',
      'photo': '',
      'created_at': now,
      'updated_at': now,
    });

    // Seed Hospital
    await db.insert('hospitals', {
      'hospital_id': hospitalId,
      'user_id': userId,
      'name': 'City Medical Hospital',
      'address': '123 Healthcare Ave, Medical District',
      'latitude': 37.7749,
      'longitude': -122.4194,
      'photo': '',
      'created_at': now,
      'updated_at': now,
    });

    // Seed Doctor (Dr. Ahmed Khan)
    await db.insert('doctors', {
      'doctor_id': doctorId,
      'user_id': userId,
      'name': 'Dr. Ahmed Khan',
      'specialization': 'Cardiologist',
      'phone': '+1 555-0199',
      'photo': '',
      'hospital_id': hospitalId,
      'created_at': now,
      'updated_at': now,
    });

    // Visit 1: 06 Oct 2026
    const visit1Id = 'visit_1';
    await db.insert('visits', {
      'visit_id': visit1Id,
      'user_id': userId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'date': '2026-10-06',
      'time': '10:00 AM',
      'reason': 'Chest discomfort and fever',
      'symptoms': 'Fever, cough, mild chest tightness',
      'diagnosis': 'Viral Infection',
      'notes': 'Rest for 5 days, drink plenty of fluids.',
      'follow_up': '2026-11-15',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 1 Medicines (3 medicines)
    await db.insert('medicines', {
      'medicine_id': 'med_1',
      'visit_id': visit1Id,
      'name': 'Panadol',
      'dose': '500mg',
      'frequency': '3 times a day',
      'duration': '5 days',
      'meal_instruction': 'After Meal',
      'instructions': 'Take with water',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('medicines', {
      'medicine_id': 'med_2',
      'visit_id': visit1Id,
      'name': 'Amoxicillin',
      'dose': '250mg',
      'frequency': '2 times a day',
      'duration': '7 days',
      'meal_instruction': 'Before Meal',
      'instructions': 'Complete full course',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('medicines', {
      'medicine_id': 'med_3',
      'visit_id': visit1Id,
      'name': 'Vitamin C',
      'dose': '1000mg',
      'frequency': 'Once daily',
      'duration': '10 days',
      'meal_instruction': 'After Meal',
      'instructions': 'Immune support',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 1 Tests (2 tests)
    await db.insert('tests', {
      'test_id': 'test_1',
      'visit_id': visit1Id,
      'name': 'Complete Blood Count (CBC)',
      'date': '2026-10-06',
      'result': 'WBC slightly elevated',
      'doctor_notes': 'Indicates mild infection',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('tests', {
      'test_id': 'test_2',
      'visit_id': visit1Id,
      'name': 'Chest X-Ray',
      'date': '2026-10-06',
      'result': 'Clear lungs, no pneumonia',
      'doctor_notes': 'Normal cardiac silhouette',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 1 Attachment (Prescription)
    await db.insert('attachments', {
      'attachment_id': 'att_1',
      'visit_id': visit1Id,
      'type': 'Prescription',
      'file_name': 'prescription_oct6.pdf',
      'local_path': '',
      'mime_type': 'application/pdf',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 2: 15 Nov 2026
    const visit2Id = 'visit_2';
    await db.insert('visits', {
      'visit_id': visit2Id,
      'user_id': userId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'date': '2026-11-15',
      'time': '11:30 AM',
      'reason': 'Follow-up checkup',
      'symptoms': 'Recovering well, slight fatigue',
      'diagnosis': 'Follow-up / Recovery',
      'notes': 'Blood pressure normal. Continue healthy diet.',
      'follow_up': '2027-01-03',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 2 Medicines (2 medicines)
    await db.insert('medicines', {
      'medicine_id': 'med_4',
      'visit_id': visit2Id,
      'name': 'Panadol',
      'dose': '500mg',
      'frequency': 'As needed',
      'duration': '3 days',
      'meal_instruction': 'After Meal',
      'instructions': 'For headache',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('medicines', {
      'medicine_id': 'med_5',
      'visit_id': visit2Id,
      'name': 'Multivitamin',
      'dose': '1 tablet',
      'frequency': 'Once daily',
      'duration': '30 days',
      'meal_instruction': 'After Meal',
      'instructions': 'Daily wellness',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 2 Tests (1 test)
    await db.insert('tests', {
      'test_id': 'test_3',
      'visit_id': visit2Id,
      'name': 'Blood Pressure Monitoring',
      'date': '2026-11-15',
      'result': '120/80 mmHg',
      'doctor_notes': 'Optimal blood pressure',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 3: 03 Jan 2027
    const visit3Id = 'visit_3';
    await db.insert('visits', {
      'visit_id': visit3Id,
      'user_id': userId,
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'date': '2027-01-03',
      'time': '09:15 AM',
      'reason': 'Routine Checkup',
      'symptoms': 'None',
      'diagnosis': 'Routine Checkup',
      'notes': 'Patient is in excellent health.',
      'follow_up': '',
      'created_at': now,
      'updated_at': now,
    });

    // Visit 3 Medicines (1 medicine)
    await db.insert('medicines', {
      'medicine_id': 'med_6',
      'visit_id': visit3Id,
      'name': 'Omega 3 Fish Oil',
      'dose': '1000mg',
      'frequency': 'Once daily',
      'duration': '60 days',
      'meal_instruction': 'With Meal',
      'instructions': 'Heart health support',
      'created_at': now,
      'updated_at': now,
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
