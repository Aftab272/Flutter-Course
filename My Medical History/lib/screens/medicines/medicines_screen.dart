import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/medical_provider.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescribed Medicines'),
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, provider, child) {
          final medicines = provider.medicines;

          if (medicines.isEmpty) {
            return const Center(child: Text('No medicines prescribed yet.', style: TextStyle(color: AppTheme.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final med = medicines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.medication, color: Colors.white),
                  ),
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dose: ${med.dose} • ${med.frequency}\nDuration: ${med.duration}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
