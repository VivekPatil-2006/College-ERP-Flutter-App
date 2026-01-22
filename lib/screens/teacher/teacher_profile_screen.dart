import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/teacher_profile_model.dart';
import 'teacher_profile_edit_screen.dart';

class TeacherProfileScreen extends StatelessWidget {

  final String teacherId;

  const TeacherProfileScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: FutureBuilder<TeacherProfile?>(
        future: firestoreService.getTeacherProfile(teacherId),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= EMPTY PROFILE =================

          if (!snapshot.hasData || snapshot.data == null) {

            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Create Profile"),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherProfileEditScreen(teacherId: teacherId),
                    ),
                  );
                },
              ),
            );
          }

          var profile = snapshot.data!;

          Uint8List? imageBytes;

          if (profile.profileImage.isNotEmpty) {
            imageBytes = base64Decode(profile.profileImage);
          }

          return SingleChildScrollView(
            child: Column(
              children: [

                // ================= HEADER =================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 30,
                  ),

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff4facfe),
                        Color(0xff00f2fe),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),

                  child: Column(
                    children: [

                      // PROFILE IMAGE
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),

                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage:
                          imageBytes != null ? MemoryImage(imageBytes) : null,

                          child: imageBytes == null
                              ? const Icon(Icons.person, size: 55)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        profile.subject,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= DETAILS SECTION =================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    children: [

                      infoTile(
                        Icons.email,
                        "Email",
                        profile.email,
                      ),

                      infoTile(
                        Icons.phone,
                        "Phone",
                        profile.phone,
                      ),

                      infoTile(
                        Icons.menu_book,
                        "Subject",
                        profile.subject,
                      ),

                      infoTile(
                        Icons.school,
                        "Experience",
                        "${profile.experience} Years",
                      ),

                      const SizedBox(height: 25),

                      // ================= EDIT BUTTON =================

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile"),

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TeacherProfileEditScreen(
                                        teacherId: teacherId),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= INFO TILE =================

  Widget infoTile(IconData icon, String title, String value) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),

        title: Text(title),

        subtitle: Text(
          value.isEmpty ? "Not Provided" : value,
        ),
      ),
    );
  }
}
