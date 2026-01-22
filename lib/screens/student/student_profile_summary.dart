import 'dart:convert';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../models/student_profile_model.dart';
import 'student_profile_screen.dart';
import 'student_progress_card.dart';

class StudentProfileSummary extends StatelessWidget {

  final String userId;

  const StudentProfileSummary({super.key, required this.userId});

  String getRandomAvatar() {
    return "https://api.dicebear.com/7.x/personas/png?seed=$userId";
  }

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return FutureBuilder<StudentProfile?>(
      future: firestoreService.getStudentProfile(userId),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No Profile Data Found"));
        }

        var profile = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [

              // ================= HEADER =================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blue],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),

                child: Column(
                  children: [

                    // PROGRESS CARD
                    StudentProgressCard(studentId: userId),

                    const SizedBox(height: 20),

                    // PROFILE IMAGE
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,

                      backgroundImage: profile.profileImage.isNotEmpty
                          ? MemoryImage(base64Decode(profile.profileImage))
                          : NetworkImage(getRandomAvatar()) as ImageProvider,
                    ),

                    const SizedBox(height: 10),

                    // NAME
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // YEAR + DEPARTMENT BADGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        buildBadge(profile.year, Colors.orange),

                        const SizedBox(width: 8),

                        buildBadge(profile.department, Colors.green),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= DETAILS =================

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    sectionTitle("Academic Details"),

                    buildInfoTile(Icons.school, "Year", profile.year),
                    buildInfoTile(Icons.apartment, "Department", profile.department),

                    const SizedBox(height: 10),

                    sectionTitle("Personal Details"),

                    buildInfoTile(Icons.email, "Email", profile.email),
                    buildInfoTile(Icons.phone, "Phone", profile.phone),
                    buildInfoTile(Icons.calendar_today, "DOB", profile.dob),
                    buildInfoTile(Icons.home, "Address", profile.address),

                    const SizedBox(height: 10),

                    sectionTitle("Parent Details"),

                    buildInfoTile(Icons.person, "Parent Name", profile.parentName),
                    buildInfoTile(Icons.call, "Parent Contact", profile.parentContact),

                    const SizedBox(height: 20),

                    // ================= EDIT BUTTON =================

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("EDIT PROFILE"),

                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentProfileScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= BADGE =================

  Widget buildBadge(String text, Color color) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white70),
      ),

      child: Text(
        text.isEmpty ? "Not Set" : text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget sectionTitle(String text) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }

  // ================= INFO TILE =================

  Widget buildInfoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? "Not Provided" : value,
        ),
      ),
    );
  }
}
