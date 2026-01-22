import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'admin_announcement_screen.dart';

class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.announcement),
        label: const Text("Announcement"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAnnouncementScreen(),
            ),
          );
        },
      ),

      body: CustomScrollView(
        slivers: [

          // ================= APP BAR HEADER =================

          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              title: const Text(""),

              background: Container(
                padding: const EdgeInsets.all(20),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff5F2EEA),
                      Color(0xff764BA2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: const [

                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Institution Overview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= DASHBOARD CONTENT =================

          SliverPadding(
            padding: const EdgeInsets.all(16),

            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.1,

              children: [

                dashboardCard(
                  icon: Icons.school,
                  title: "Students",
                  color: Colors.blue,
                  stream: firestoreService.getStudentCountStream(),
                ),

                dashboardCard(
                  icon: Icons.person,
                  title: "Teachers",
                  color: Colors.green,
                  stream: firestoreService.getTeacherCountStream(),
                ),

                dashboardCard(
                  icon: Icons.assignment,
                  title: "Assignments",
                  color: Colors.orange,
                  stream: firestoreService.getAssignmentCountStream(),
                ),

                dashboardCard(
                  icon: Icons.upload_file,
                  title: "Submissions",
                  color: Colors.purple,
                  stream: firestoreService.getTotalSubmissionCountStream(),
                ),

              ],
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 90),
          ),
        ],
      ),
    );
  }

  // ================= DASHBOARD TILE =================

  Widget dashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required Stream<int> stream,
  }) {

    return StreamBuilder<int>(
      stream: stream,

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icon, color: color),
              ),

              const Spacer(),

              Text(
                snapshot.data.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
