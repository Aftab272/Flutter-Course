import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/medical_provider.dart';
import '../history/visit_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalProvider>(context);
    final visits = provider.visits.where((v) {
      if (_query.isEmpty) return false;
      final q = _query.toLowerCase();
      final diagnosisMatch = v.diagnosis?.toLowerCase().contains(q) ?? false;
      final doctorMatch = v.doctor?.name.toLowerCase().contains(q) ?? false;
      final medicineMatch = v.medicines.any((m) => m.name.toLowerCase().contains(q));
      final testMatch = v.tests.any((t) => t.name.toLowerCase().contains(q));
      return diagnosisMatch || doctorMatch || medicineMatch || testMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search doctors, medicines, diagnosis, tests...',
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Type to search across your medical records', style: TextStyle(color: AppTheme.textSecondary)))
          : visits.isEmpty
              ? const Center(child: Text('No matching records found', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: visits.length,
                  itemBuilder: (context, index) {
                    final visit = visits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(visit.doctor?.name ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Diagnosis: ${visit.diagnosis ?? "-"}\nDate: ${visit.date}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: visit)),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
