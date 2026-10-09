import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medical_provider.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../visits/add_visit_wizard.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports & Tests'),
      ),
      body: Consumer<MedicalProvider>(
        builder: (context, provider, child) {
          final tests = provider.tests;

          if (tests.isEmpty) {
            return EmptyStateWidget(
              title: 'No Medical Reports Yet',
              message: 'Medical test results and uploaded reports will appear here.',
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
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(Icons.description, color: Colors.white),
                  ),
                  title: Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Date: ${test.date}\nResult: ${test.result ?? "Normal"}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Open preview
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
