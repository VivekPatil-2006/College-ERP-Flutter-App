import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_student_list_screen.dart';
import 'admin_teacher_list_screen.dart';
import 'admin_notification_screen.dart';
import 'admin_home_screen.dart';

class AdminDashboard extends StatefulWidget {

  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    final screens = [
      const AdminHomeScreen(),
      const AdminStudentListScreen(),
      const AdminTeacherListScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),

        ],
      ),

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Students",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Teachers",
          ),

        ],
      ),
    );
  }
}
