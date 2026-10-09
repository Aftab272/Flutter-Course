import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/visit.dart';
import '../../providers/medical_provider.dart';

class VisitDetailsScreen extends StatelessWidget {
  final Visit visit;

  const VisitDetailsScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Visit'),
                  content: const Text('Are you sure you want to delete this medical visit?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await Provider.of<MedicalProvider>(context, listen: false).deleteVisit(visit.visitId);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor: ${visit.doctor?.name ?? "Unknown"}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Hospital: ${visit.hospital?.name ?? "Hospital"}', style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Date: ${visit.date} at ${visit.time}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnosis & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Diagnosis: ${visit.diagnosis ?? "General"}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
                    const SizedBox(height: 4),
                    Text('Reason: ${visit.reason ?? "-"}'),
                    const SizedBox(height: 4),
                    Text('Symptoms: ${visit.symptoms ?? "-"}'),
                    const SizedBox(height: 4),
                    Text('Doctor Notes: ${visit.notes ?? "-"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Prescribed Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (visit.medicines.isEmpty)
              const Text('No medicines prescribed.', style: TextStyle(color: AppTheme.textSecondary))
            else
              ...visit.medicines.map((m) => Card(
                    child: ListTile(
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${m.dose} • ${m.frequency} • ${m.duration}'),
                    ),
                  )),
            const SizedBox(height: 16),
            const Text('Medical Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (visit.tests.isEmpty)
              const Text('No tests ordered.', style: TextStyle(color: AppTheme.textSecondary))
            else
              ...visit.tests.map((t) => Card(
                    child: ListTile(
                      title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Result: ${t.result ?? "Pending"}'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
