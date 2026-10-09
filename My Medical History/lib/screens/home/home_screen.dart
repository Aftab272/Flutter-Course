import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/medical_provider.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../doctors/doctors_screen.dart';
import '../history/history_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../visits/add_visit_wizard.dart';
import '../search/search_screen.dart';
import '../doctors/doctor_profile_screen.dart';
import '../history/visit_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadData();
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeDashboardTab(),
    DoctorsScreen(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(body: LoadingWidget(message: 'Loading dashboard...'));
        }
        if (provider.errorMessage != null) {
          return Scaffold(body: ErrorStateWidget(message: provider.errorMessage!, onRetry: () => provider.loadData()));
        }

        final stats = provider.statistics;
        final visits = provider.visits;
        final doctors = provider.doctors;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top greeting & avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                            ),
                            Text(
                              'John Doe',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search bar
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: AppTheme.textSecondary),
                            SizedBox(width: 12),
                            Text(
                              'Search your medical history...',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary CTA: + Add Medical Visit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVisitWizard()));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medical Visit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2x2 Statistics Grid
                    const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Doctors', '${stats['doctors'] ?? 0}', Icons.support_agent, Colors.blue),
                        _buildStatCard('Medical Visits', '${stats['visits'] ?? 0}', Icons.medical_services, Colors.green),
                        _buildStatCard('Medicines', '${stats['medicines'] ?? 0}', Icons.medication, Colors.orange),
                        _buildStatCard('Reports', '${stats['reports'] ?? 0}', Icons.description, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Visits
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Visits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        TextButton(
                          onPressed: () {
                            // Navigate to history tab
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (visits.isEmpty)
                      const Text('No medical visits recorded yet.', style: TextStyle(color: AppTheme.textSecondary))
                    else
                      ...visits.take(3).map((visit) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                visit.doctor?.name ?? 'Dr. Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('${visit.hospital?.name ?? "Hospital"} • ${visit.date}'),
                                  const SizedBox(height: 4),
                                  Text('Diagnosis: ${visit.diagnosis ?? "General"}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: visit)),
                                );
                              },
                            ),
                          )),
                    const SizedBox(height: 20),

                    // Recent Doctors
                    const Text('Recent Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    if (doctors.isEmpty)
                      const Text('No doctors added yet.', style: TextStyle(color: AppTheme.textSecondary))
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doc)),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                      child: const Icon(Icons.person, color: AppTheme.primaryColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      doc.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      doc.specialization,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
