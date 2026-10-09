import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/doctor.dart';
import '../../providers/medical_provider.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final Doctor? doctor;

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _specialization;
  late String _phone;
  String? _selectedHospitalId;

  @override
  void initState() {
    super.initState();
    _name = widget.doctor?.name ?? '';
    _specialization = widget.doctor?.specialization ?? '';
    _phone = widget.doctor?.phone ?? '';
    _selectedHospitalId = widget.doctor?.hospitalId;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalProvider>(context);
    final hospitals = provider.hospitals;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor == null ? 'Add Doctor' : 'Edit Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Doctor Name *', hintText: 'e.g. Dr. Ahmed Khan'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter doctor name' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _specialization,
                decoration: const InputDecoration(labelText: 'Specialization *', hintText: 'e.g. Cardiologist'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter specialization' : null,
                onSaved: (val) => _specialization = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone Number', hintText: 'e.g. +1 555-0199'),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phone = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedHospitalId,
                decoration: const InputDecoration(labelText: 'Hospital / Clinic'),
                items: hospitals.map((h) => DropdownMenuItem(value: h.hospitalId, child: Text(h.name))).toList(),
                onChanged: (val) => setState(() => _selectedHospitalId = val),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final now = DateTime.now().toIso8601String();
                    final doc = Doctor(
                      doctorId: widget.doctor?.doctorId ?? const Uuid().v4(),
                      userId: provider.userId,
                      name: _name,
                      specialization: _specialization,
                      phone: _phone,
                      hospitalId: _selectedHospitalId,
                      createdAt: widget.doctor?.createdAt ?? now,
                      updatedAt: now,
                    );
                    await provider.saveDoctor(doc);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(widget.doctor == null ? 'Save Doctor' : 'Update Doctor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
