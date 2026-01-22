import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AdminHomeScreen extends StatelessWidget {

  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff5F2EEA),
                    Color(0xff764BA2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Manage your institution easily",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [

                  // ================= STAT GRID =================

                  Row(
                    children: [

                      Expanded(
                        child: statCard(
                          title: "Students",
                          icon: Icons.school,
                          color: Colors.blue,
                          stream: firestoreService.getStudentCountStream(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard(
                          title: "Teachers",
                          icon: Icons.person,
                          color: Colors.green,
                          stream: firestoreService.getTeacherCountStream(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      Expanded(
                        child: statCard(
                          title: "Assignments",
                          icon: Icons.assignment,
                          color: Colors.orange,
                          stream: firestoreService.getAssignmentCountStream(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard(
                          title: "Submissions",
                          icon: Icons.upload_file,
                          color: Colors.purple,
                          stream: firestoreService.getTotalSubmissionCountStream(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ================= QUICK ACTIONS =================

                  sectionTitle("Quick Actions"),

                  const SizedBox(height: 10),

                  actionTile(
                    icon: Icons.school,
                    title: "Manage Students",
                    onTap: () {
                      Navigator.pushNamed(context, '/adminStudents');
                    },
                  ),

                  actionTile(
                    icon: Icons.person,
                    title: "Manage Teachers",
                    onTap: () {
                      Navigator.pushNamed(context, '/adminTeachers');
                    },
                  ),

                  const SizedBox(height: 20),

                  // ================= RECENT ACTIVITY (UI READY) =================

                  sectionTitle("System Overview"),

                  const SizedBox(height: 10),

                  infoCard(
                    icon: Icons.info,
                    title: "System Status",
                    subtitle: "All services running normally",
                    color: Colors.green,
                  ),

                  infoCard(
                    icon: Icons.storage,
                    title: "Database",
                    subtitle: "Firestore connected successfully",
                    color: Colors.blue,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  Widget statCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
  }) {

    return StreamBuilder<int>(
      stream: stream,

      builder: (context, snapshot) {

        String value = snapshot.hasData
            ? snapshot.data.toString()
            : "...";

        return Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),

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

              const SizedBox(height: 15),

              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= ACTION TILE =================

  Widget actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(icon, color: Colors.indigo),
        ),

        title: Text(title),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }

  // ================= INFO CARD =================

  Widget infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),

        title: Text(title),

        subtitle: Text(subtitle),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget sectionTitle(String title) {

    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
