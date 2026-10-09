import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/visit.dart';
import '../../models/medicine.dart';
import '../../models/test_model.dart';
import '../../models/attachment.dart';
import '../../providers/medical_provider.dart';
import '../../services/location_service.dart';

class AddVisitWizard extends StatefulWidget {
  const AddVisitWizard({super.key});

  @override
  State<AddVisitWizard> createState() => _AddVisitWizardState();
}

class _AddVisitWizardState extends State<AddVisitWizard> {
  int _currentStep = 0;

  // Visit form state
  String? _selectedDoctorId;
  String? _selectedHospitalId;
  final String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String _time = '10:00 AM';
  String _reason = '';
  String _symptoms = '';
  String _diagnosis = '';
  String _notes = '';
  final String _followUp = '';

  final List<Medicine> _medicines = [];
  final List<TestModel> _tests = [];
  final List<Attachment> _attachments = [];

  // Controllers for adding medicine/test dynamically
  final _medNameController = TextEditingController();
  final _medDoseController = TextEditingController();
  final _medFreqController = TextEditingController();
  final _medDurationController = TextEditingController();

  final _testNameController = TextEditingController();
  final _testResultController = TextEditingController();

  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Visit'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 6) {
            setState(() => _currentStep++);
          } else {
            _saveVisit(provider);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Doctor'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: const InputDecoration(labelText: 'Select Doctor *'),
                  items: provider.doctors.map((d) => DropdownMenuItem(value: d.doctorId, child: Text('${d.name} (${d.specialization})'))).toList(),
                  onChanged: (val) => setState(() => _selectedDoctorId = val),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Location'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedHospitalId,
                  decoration: const InputDecoration(labelText: 'Select Hospital / Clinic'),
                  items: provider.hospitals.map((h) => DropdownMenuItem(value: h.hospitalId, child: Text(h.name))).toList(),
                  onChanged: (val) => setState(() => _selectedHospitalId = val),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final loc = await _locationService.getCurrentLocation();
                    if (loc != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Location fetched: ${loc['address']}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current GPS Location'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Details'),
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Diagnosis *', hintText: 'e.g. Viral Infection'),
                  onChanged: (val) => _diagnosis = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reason for Visit', hintText: 'e.g. Fever & Cough'),
                  onChanged: (val) => _reason = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Symptoms', hintText: 'e.g. Headache, fatigue'),
                  onChanged: (val) => _symptoms = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Doctor Notes', hintText: 'e.g. Rest for 5 days'),
                  onChanged: (val) => _notes = val,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Medicines'),
            content: Column(
              children: [
                TextField(controller: _medNameController, decoration: const InputDecoration(labelText: 'Medicine Name')),
                const SizedBox(height: 8),
                TextField(controller: _medDoseController, decoration: const InputDecoration(labelText: 'Dose (e.g. 500mg)')),
                const SizedBox(height: 8),
                TextField(controller: _medFreqController, decoration: const InputDecoration(labelText: 'Frequency (e.g. 3 times daily)')),
                const SizedBox(height: 8),
                TextField(controller: _medDurationController, decoration: const InputDecoration(labelText: 'Duration (e.g. 5 days)')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_medNameController.text.isNotEmpty) {
                      setState(() {
                        _medicines.add(Medicine(
                          medicineId: const Uuid().v4(),
                          visitId: '',
                          name: _medNameController.text,
                          dose: _medDoseController.text,
                          frequency: _medFreqController.text,
                          duration: _medDurationController.text,
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        ));
                        _medNameController.clear();
                        _medDoseController.clear();
                        _medFreqController.clear();
                        _medDurationController.clear();
                      });
                    }
                  },
                  child: const Text('Add Medicine'),
                ),
                const SizedBox(height: 12),
                ..._medicines.map((m) => ListTile(
                      title: Text(m.name),
                      subtitle: Text('${m.dose} • ${m.frequency} • ${m.duration}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _medicines.remove(m)),
                      ),
                    )),
              ],
            ),
          ),
          Step(
            title: const Text('Tests'),
            content: Column(
              children: [
                TextField(controller: _testNameController, decoration: const InputDecoration(labelText: 'Test Name')),
                const SizedBox(height: 8),
                TextField(controller: _testResultController, decoration: const InputDecoration(labelText: 'Test Result / Notes')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_testNameController.text.isNotEmpty) {
                      setState(() {
                        _tests.add(TestModel(
                          testId: const Uuid().v4(),
                          visitId: '',
                          name: _testNameController.text,
                          date: _date,
                          result: _testResultController.text,
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        ));
                        _testNameController.clear();
                        _testResultController.clear();
                      });
                    }
                  },
                  child: const Text('Add Medical Test'),
                ),
                const SizedBox(height: 12),
                ..._tests.map((t) => ListTile(
                      title: Text(t.name),
                      subtitle: Text('Result: ${t.result ?? "Pending"}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _tests.remove(t)),
                      ),
                    )),
              ],
            ),
          ),
          Step(
            title: const Text('Prescription'),
            content: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _attachments.add(Attachment(
                        attachmentId: const Uuid().v4(),
                        visitId: '',
                        type: 'Prescription',
                        fileName: 'prescription_scan.pdf',
                        localPath: '',
                        mimeType: 'application/pdf',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                      ));
                    });
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Prescription PDF / Image'),
                ),
                const SizedBox(height: 12),
                ..._attachments.map((a) => ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primaryColor),
                      title: Text(a.fileName),
                      subtitle: Text(a.type),
                    )),
              ],
            ),
          ),
          Step(
            title: const Text('Review'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnosis: $_diagnosis', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Date: $_date at $_time'),
                Text('Medicines: ${_medicines.length}'),
                Text('Tests: ${_tests.length}'),
                Text('Attachments: ${_attachments.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVisit(MedicalProvider provider) async {
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
      return;
    }

    final visitId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final visit = Visit(
      visitId: visitId,
      userId: provider.userId,
      doctorId: _selectedDoctorId!,
      hospitalId: _selectedHospitalId,
      date: _date,
      time: _time,
      reason: _reason,
      symptoms: _symptoms,
      diagnosis: _diagnosis,
      notes: _notes,
      followUp: _followUp,
      createdAt: now,
      updatedAt: now,
    );

    final meds = _medicines.map((m) => m.copyWith(visitId: visitId)).toList();
    final tsts = _tests.map((t) => t.copyWith(visitId: visitId)).toList();
    final atts = _attachments.map((a) => a.copyWith(visitId: visitId)).toList();

    await provider.saveVisit(visit: visit, medicines: meds, tests: tsts, attachments: atts);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
