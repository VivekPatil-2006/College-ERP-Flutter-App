import 'package:flutter/material.dart';
import 'package:student_teacher_portal/screens/teacher/teacher_assignment_screen.dart';

import 'create_assignment_screen.dart';
import 'teacher_submission_screen.dart';
import 'teacher_profile_screen.dart';
import 'teacher_recent_submission_screen.dart';
import '../auth/login_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/assignment_model.dart';
import 'edit_assignment_screen.dart';
import '../../models/notification_model.dart';

class TeacherDashboard extends StatefulWidget {

  final String userId;
  final String teacherName;

  const TeacherDashboard({
    super.key,
    required this.userId,
    required this.teacherName,
  });

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {

  int currentIndex = 0;

  final FirestoreService firestoreService = FirestoreService();

  // ================= DELETE CONFIRM =================

  void confirmDelete(String assignmentId) {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Delete Assignment"),
        content: const Text("Are you sure you want to delete this assignment?"),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),

            onPressed: () async {

              Navigator.pop(context);

              // ✅ FIXED API
              await firestoreService.deleteAssignment(
                widget.userId,
                assignmentId,
              );

              // ✅ FIXED NOTIFICATION
              await firestoreService.sendNotification(
                AppNotification(
                  title: "Assignment Deleted",
                  message: "An assignment was removed",
                  role: "student",
                  userId: "all",
                ),
              );

              setState(() {});
            },

            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= ASSIGNMENT TAB =================

  Widget assignmentTab() {

    return StreamBuilder<List<Assignment>>(

      // ✅ ONLY THIS TEACHER'S ASSIGNMENTS
      stream: firestoreService.getTeacherAssignments(widget.userId),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No Assignments Created",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        var assignments = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),

          child: ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: assignments.length,

            itemBuilder: (context, index) {

              var assignment = assignments[index];

              return Card(
                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(

                  title: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 4),

                      Text("Category: ${assignment.category}"),

                      const SizedBox(height: 2),

                      // ✅ TIMESTAMP FORMAT FIX
                      Text(
                        "Due: ${assignment.dueDate.toDate().toString().split(' ')[0]}",
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton(

                    itemBuilder: (_) => [

                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),

                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],

                    onSelected: (value) {

                      if (value == "edit") {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditAssignmentScreen(
                                  assignment: assignment,
                                  teacherId: widget.userId, // ✅ REQUIRED
                                ),
                          ),
                        );
                      }

                      if (value == "delete") {
                        confirmDelete(assignment.id);
                      }
                    },
                  ),

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherSubmissionScreen(
                          assignmentId: assignment.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= MAIN BUILD =================

  @override
  Widget build(BuildContext context) {

    final screens = [

      TeacherAssignmentScreen(
        teacherId: widget.userId,
        teacherName: widget.teacherName,
      ),

      const TeacherRecentSubmissionScreen(),

      TeacherProfileScreen(
        teacherId: widget.userId,
      ),
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        centerTitle: true,

        actions: [

          IconButton(
            tooltip: "Create Assignment",
            icon: const Icon(Icons.add_circle_outline),

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateAssignmentScreen(
                    teacherId: widget.userId, // ✅ FIXED
                    teacherName: widget.teacherName,
                  ),
                ),
              );
            },
          ),

          IconButton(
            tooltip: "Logout",
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
          setState(() => currentIndex = index);
        },

        selectedItemColor: Colors.indigo,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Assignments",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Submissions",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
