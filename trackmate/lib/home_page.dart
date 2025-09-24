import 'package:flutter/material.dart';
import 'package:trackmate/service/auth_service.dart';

import 'package:trackmate/ui/buses_page/buses_page.dart';
import 'package:trackmate/ui/dashboard_page/dashboard_page.dart';
import 'package:trackmate/ui/drivers_page/drivers_page.dart';

import 'package:trackmate/ui/student_page/student_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final AuthService _authService = AuthService();

  // Pages for right-side content
  final List<Widget> _pages =  [
    const DashboardPage(),
    StudentsPage(),
    const DriversPage(),
    BusesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Fixed Drawer)
          Container(
            width: 220,
            color: Colors.deepPurple,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Admin Panel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white54, height: 40),

                _buildMenuItem(Icons.dashboard, "Dashboard", 0),
                _buildMenuItem(Icons.person, "Students", 1),
                _buildMenuItem(Icons.drive_eta, "Drivers", 2),
                _buildMenuItem(Icons.directions_bus, "Buses", 3),

                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await _authService.signOut();
                    Navigator.pop(context); // Back to login
                  },
                ),
              ],
            ),
          ),

          // Right side: content changes
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 60,
                  color: Colors.grey.shade200,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    ["Dashboard", "Students", "Drivers", "Buses"][_selectedIndex],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Page Content
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.yellow : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.yellow : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index; // just change content
        });
      },
    );
  }
}
