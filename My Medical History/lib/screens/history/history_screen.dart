import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/medical_provider.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'visit_details_screen.dart';
import '../visits/add_visit_wizard.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History Timeline'),
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, provider, child) {
          final visits = provider.visits;

          if (visits.isEmpty) {
            return EmptyStateWidget(
              title: 'No Medical Visits Yet',
              message: 'Your medical history timeline will appear here once you add visits.',
              buttonText: 'Add Medical Visit',
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddVisitWizard()),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            visit.date,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          Text(
                            visit.time,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        visit.doctor?.name ?? 'Dr. Unknown',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(visit.hospital?.name ?? 'Hospital', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Text(
                        'Diagnosis: ${visit.diagnosis ?? "General"}',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildChip('${visit.medicines.length} Medicines', Icons.medication),
                          const SizedBox(width: 8),
                          _buildChip('${visit.tests.length} Tests', Icons.science),
                          const SizedBox(width: 8),
                          if (visit.attachments.isNotEmpty) _buildChip('${visit.attachments.length} Attachment', Icons.description),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: visit)),
                            );
                          },
                          child: const Text('View Full Details →'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}
