import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor.dart';
import '../../providers/medical_provider.dart';
import '../visits/add_visit_wizard.dart';
import '../history/visit_details_screen.dart';
import 'add_edit_doctor_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditDoctorScreen(doctor: doctor)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Doctor'),
                  content: Text('Are you sure you want to delete ${doctor.name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await Provider.of<MedicalProvider>(context, listen: false).deleteDoctor(doctor.doctorId);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, provider, child) {
          final visits = provider.visits.where((v) => v.doctorId == doctor.doctorId).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doctor.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        doctor.specialization,
                        style: const TextStyle(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      if (doctor.phone != null && doctor.phone!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 16),
                          label: Text('Call ${doctor.phone}'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hospital & Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(doctor.hospital?.name ?? 'City Medical Hospital', style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(doctor.hospital?.address ?? '123 Healthcare Ave', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, color: AppTheme.primaryColor),
                                SizedBox(width: 8),
                                Text('Map Preview', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Visit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddVisitWizard()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Visit'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (visits.isEmpty)
                  const Text('No visits recorded for this doctor yet.', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ...visits.map((visit) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Visit Date: ${visit.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Diagnosis: ${visit.diagnosis ?? "General"}\nMedicines: ${visit.medicines.length} | Tests: ${visit.tests.length}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: visit)),
                            );
                          },
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
