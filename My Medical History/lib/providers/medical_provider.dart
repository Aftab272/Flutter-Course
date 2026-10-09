import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/visit.dart';
import '../models/medicine.dart';
import '../models/test_model.dart';
import '../models/attachment.dart';
import '../repositories/medical_repository.dart';

class MedicalProvider extends ChangeNotifier {
  final MedicalRepository _repository = MedicalRepository();
  
  String userId = 'sample_user_1';
  bool isLoading = false;
  String? errorMessage;

  List<Doctor> doctors = [];
  List<Hospital> hospitals = [];
  List<Visit> visits = [];
  List<Medicine> medicines = [];
  List<TestModel> tests = [];
  Map<String, int> statistics = {'doctors': 0, 'visits': 0, 'medicines': 0, 'reports': 0};

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      doctors = await _repository.getDoctors(userId);
      hospitals = await _repository.getHospitals(userId);
      visits = await _repository.getVisits(userId);
      medicines = await _repository.getAllMedicines(userId);
      tests = await _repository.getAllTests(userId);
      statistics = await _repository.getStatistics(userId);
    } catch (e) {
      errorMessage = 'Unable to load your medical history: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDoctor(Doctor doctor) async {
    await _repository.saveDoctor(doctor);
    await loadData();
  }

  Future<void> deleteDoctor(String doctorId) async {
    await _repository.deleteDoctor(doctorId);
    await loadData();
  }

  Future<void> saveHospital(Hospital hospital) async {
    await _repository.saveHospital(hospital);
    await loadData();
  }

  Future<void> deleteHospital(String hospitalId) async {
    await _repository.deleteHospital(hospitalId);
    await loadData();
  }

  Future<void> saveVisit({
    required Visit visit,
    required List<Medicine> medicines,
    required List<TestModel> tests,
    required List<Attachment> attachments,
  }) async {
    await _repository.saveVisit(
      visit: visit,
      medicines: medicines,
      tests: tests,
      attachments: attachments,
    );
    await loadData();
  }

  Future<void> deleteVisit(String visitId) async {
    await _repository.deleteVisit(visitId);
    await loadData();
  }
}
