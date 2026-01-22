import 'package:flutter/material.dart';

import 'student_assignment_screen.dart';
import 'student_profile_summary.dart';
import 'student_notification_screen.dart';
import '../auth/login_screen.dart';
import '../../services/firestore_service.dart';

class StudentDashboard extends StatefulWidget {

  final String userId;

  const StudentDashboard({
    super.key,
    required this.userId,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  int currentIndex = 0;

  late final List<Widget> screens;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    // Screens created ONCE (kept alive)
    screens = [

      // PROFILE
      StudentProfileSummary(
        userId: widget.userId,
      ),

      // ASSIGNMENTS
      StudentAssignmentScreen(
        studentId: widget.userId,
      ),

      // NOTIFICATIONS
      StudentNotificationScreen(
        studentId: widget.userId,
      ),
    ];
  }

  // ================= LOGOUT =================

  void logout() {

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ================= APP BAR =================

      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      // ================= LOGOUT FAB =================

      floatingActionButton: FloatingActionButton(
        tooltip: "Logout",
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout),
        onPressed: logout,
      ),

      // ================= BOTTOM NAV =================

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),

        child: BottomNavigationBar(

          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,

          showUnselectedLabels: true,

          onTap: (index) {
            setState(() => currentIndex = index);
          },

          items: [

            // ================= PROFILE =================

            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: "Profile",
            ),

            // ================= ASSIGNMENTS =================

            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: "Assignments",
            ),

            // ================= NOTIFICATIONS =================

            BottomNavigationBarItem(

              icon: StreamBuilder<int>(

                stream: firestoreService
                    .getUnreadNotificationCount(widget.userId),

                builder: (context, snapshot) {

                  final unread = snapshot.data ?? 0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [

                      const Icon(Icons.notifications_none),

                      if (unread > 0)

                        Positioned(
                          right: -6,
                          top: -4,

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Text(
                              unread > 9 ? "9+" : unread.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              activeIcon: const Icon(Icons.notifications),
              label: "Notifications",
            ),

          ],
        ),
      ),
    );
  }
}
