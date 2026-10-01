import 'package:flutter/material.dart';
import 'profile_image.dart';

void main() {
  runApp(const StudentApp());
}

/// Root widget of the application configuring theme and home page.
class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Digital ID Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Navy Blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF0284C7), // Sky Blue Accent
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CampusDashboard(),
    );
  }
}

/// Main Campus Dashboard Screen
class CampusDashboard extends StatefulWidget {
  const CampusDashboard({super.key});

  @override
  State<CampusDashboard> createState() => _CampusDashboardState();
}

class _CampusDashboardState extends State<CampusDashboard> {
  // Student Information
  final String studentName = "M Aftab Akram";
  final String rollNumber = "FA24-BSE-060";
  final String department = "Software Engineering";
  final String session = "2024-2028";
  final String semester = "2nd Semester";

  // List of Enrolled Courses
  final List<Map<String, String>> courses = [
    {
      "name": "Web Engineering",
      "code": "CS-301",
      "instructor": "Dr. Sarah Khan",
      "icon": "code"
    },
    {
      "name": "Software Engineering",
      "code": "SE-202",
      "instructor": "Prof. Ali Raza",
      "icon": "developer_mode"
    },
    {
      "name": "Computer Networks",
      "code": "CN-401",
      "instructor": "Engr. Usama Ahmed",
      "icon": "lan"
    },
    {
      "name": "Artificial Intelligence",
      "code": "AI-303",
      "instructor": "Dr. Fatima Noor",
      "icon": "psychology"
    },
    {
      "name": "Information Security",
      "code": "IS-405",
      "instructor": "Prof. Hamza Tariq",
      "icon": "security"
    },
  ];

  // Quick Notes List & Controller
  final List<String> quickNotes = [
    "Prepare Web Engineering assignment by Friday.",
    "Mid-term exam schedule announced for next week."
  ];
  final TextEditingController _noteController = TextEditingController();

  // Selected Drawer Navigation Index
  int _selectedNavIndex = 0;
  String _searchQuery = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Method to add a quick note
  void _addQuickNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        quickNotes.add(text);
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note added successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a note before submitting."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper icon getter
  IconData _getCourseIcon(String iconName) {
    switch (iconName) {
      case "code":
        return Icons.code_rounded;
      case "developer_mode":
        return Icons.developer_mode_rounded;
      case "lan":
        return Icons.lan_rounded;
      case "psychology":
        return Icons.psychology_rounded;
      case "security":
        return Icons.security_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtered courses based on search query
    final filteredCourses = courses.where((course) {
      final name = course["name"]!.toLowerCase();
      final code = course["code"]!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    // ==========================================
    // 1. SCAFFOLD WIDGET (Main Screen Shell)
    // ==========================================
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light Slate Background

      // ==========================================
      // 1. APPBAR WIDGET (Top Navigation Bar)
      // ==========================================
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        backgroundColor: const Color(0xFF1E3A8A), // Primary Navy Blue
        foregroundColor: Colors.white,
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search courses...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                'Campus Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
        // Drawer Menu Icon is built-in via Scaffold's drawer property
        // Search Action Icon in AppBar
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close Search' : 'Search Courses',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = "";
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================
      // 1. DRAWER WIDGET (Side Navigation Menu)
      // ==========================================
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header with Student Profile
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.memory(
                    studentProfileBytes,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Text(
                      studentName.isNotEmpty ? studentName[0] : "S",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
              ),
              accountName: Text(
                studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                "$rollNumber | $department",
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
            
            // Workable Drawer Menu Items
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF1E3A8A)),
              title: const Text('Dashboard'),
              selected: _selectedNavIndex == 0,
              selectedTileColor: const Color(0xFFE0F2FE),
              onTap: () {
                setState(() => _selectedNavIndex = 0);
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_rounded, color: Color(0xFF1E3A8A)),
              title: const Text('Digital ID Card'),
              selected: _selectedNavIndex == 1,
              selectedTileColor: const Color(0xFFE0F2FE),
              onTap: () {
                setState(() => _selectedNavIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF1E3A8A)),
              title: const Text('Enrolled Courses'),
              selected: _selectedNavIndex == 2,
              selectedTileColor: const Color(0xFFE0F2FE),
              onTap: () {
                setState(() => _selectedNavIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_alt_rounded, color: Color(0xFF1E3A8A)),
              title: const Text('Quick Notes'),
              selected: _selectedNavIndex == 3,
              selectedTileColor: const Color(0xFFE0F2FE),
              onTap: () {
                setState(() => _selectedNavIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_rounded, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings page clicked')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Colors.grey),
              title: const Text('About App'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Student Digital ID Card',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Developed for Campus Dashboard Viva',
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Batch $session',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      // ==========================================
      // MAIN BODY CONTENT (Responsive Scroll View)
      // ==========================================
      body: SingleChildScrollView(
        child: Padding(
          // ==========================================
          // PADDING WIDGET (Outer Screen Spacing)
          // ==========================================
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // ==========================================
            // COLUMN WIDGET (Vertical Layout)
            // ==========================================
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ------------------------------------------
              // SECTION 1: DIGITAL ID CARD
              // ------------------------------------------
              if (_selectedNavIndex == 0 || _selectedNavIndex == 1) ...[
                const Text(
                  'Digital Student ID Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12), // SIZEDBOX WIDGET (Spacing)

                // ==========================================
                // CARD WIDGET (Student Digital ID Container)
                // ==========================================
                Card(
                  elevation: 6,
                  shadowColor: const Color(0x331E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    // ==========================================
                    // CONTAINER WIDGET (ID Card Styling & Layout)
                    // ==========================================
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header Row (University Name & Chip/Logo)
                        Row(
                          // ==========================================
                          // ROW WIDGET (Horizontal Arrangement)
                          // ==========================================
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'CAMPUS DIGITAL ID',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20), // SIZEDBOX WIDGET

                        // Main Profile Details Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ==========================================
                            // STACK WIDGET (Profile Pic + Green Status Dot)
                            // ==========================================
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // CIRCLEAVATAR WIDGET (Student Profile Pic)
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white24,
                                  child: CircleAvatar(
                                    radius: 37,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: Image.memory(
                                        studentProfileBytes,
                                        width: 74,
                                        height: 74,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.person_rounded,
                                          size: 48,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Active/Online Status Green Dot
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E), // Bright Green
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 16), // SIZEDBOX WIDGET

                            // Student Info Text Block
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student Name
                                  Text(
                                    studentName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Roll Number
                                  Text(
                                    "Roll No: $rollNumber",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Department
                                  Text(
                                    department,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20), // SIZEDBOX WIDGET

                        const Divider(color: Colors.white24, height: 1),

                        const SizedBox(height: 12),

                        // Card Footer Info Row (Session & Semester)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCardFooterDetail("SESSION", session),
                            _buildCardFooterDetail("SEMESTER", semester),
                            _buildCardFooterDetail("STATUS", "Enrolled"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ------------------------------------------
              // SECTION 2: ENROLLED COURSES LIST
              // ------------------------------------------
              if (_selectedNavIndex == 0 || _selectedNavIndex == 2) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enrolled Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredCourses.length} Courses',
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ==========================================
                // LISTVIEW.BUILDER WIDGET (Dynamic Scrollable List)
                // ==========================================
                filteredCourses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            "No courses match your search.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true, // Allows ListView inside Column
                        physics: const NeverScrollableScrollPhysics(), // Scroll managed by parent
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];

                          // ==========================================
                          // LISTTILE WIDGET (Single Course Row Item)
                          // ==========================================
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Icon(
                                  _getCourseIcon(course["icon"]!),
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                              title: Text(
                                course["name"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "${course["code"]} • ${course["instructor"]}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Selected Course: ${course["name"]}"),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
              ],

              // ------------------------------------------
              // SECTION 3: QUICK NOTES & INPUT
              // ------------------------------------------
              if (_selectedNavIndex == 0 || _selectedNavIndex == 3) ...[
                const Text(
                  'Quick Notes & Dashboard Input',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),

                // Card wrapping input & note submission
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // TEXTFIELD WIDGET (User Input Field)
                        // ==========================================
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Enter your note...', // Required hint text
                            prefixIcon: const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF1E3A8A),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E3A8A),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==========================================
                        // ELEVATEDBUTTON WIDGET (Submit Button)
                        // ==========================================
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _addQuickNote,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        // Display existing saved notes if any
                        if (quickNotes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Saved Notes:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...quickNotes.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String note = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        quickNotes.removeAt(idx);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build footer items on Digital ID Card
  Widget _buildCardFooterDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
