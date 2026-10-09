import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/medical_provider.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'doctor_profile_screen.dart';
import 'add_edit_doctor_screen.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, provider, child) {
          final doctors = provider.doctors;

          if (doctors.isEmpty) {
            return EmptyStateWidget(
              title: 'No Doctors Added Yet',
              message: 'Add your first doctor to start tracking medical visits and prescriptions.',
              buttonText: 'Add Doctor',
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 32),
                  ),
                  title: Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(doc.specialization, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(doc.hospital?.name ?? 'City Medical Hospital', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${doc.visitCount} Visits Recorded', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doc)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
