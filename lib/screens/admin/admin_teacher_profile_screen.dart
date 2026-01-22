import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../models/teacher_profile_model.dart';

class AdminTeacherProfileScreen extends StatelessWidget {

  final String teacherId;

  const AdminTeacherProfileScreen({
    super.key,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Teacher Profile"),
        centerTitle: true,
      ),

      body: FutureBuilder<TeacherProfile?>(
        future: firestoreService.getTeacherProfile(teacherId),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var profile = snapshot.data!;

          Uint8List? imageBytes;

          if (profile.profileImage.isNotEmpty) {
            imageBytes = base64Decode(profile.profileImage);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [

                // ================= PROFILE IMAGE =================

                CircleAvatar(
                  radius: 65,

                  backgroundImage:
                  imageBytes != null ? MemoryImage(imageBytes) : null,

                  child: imageBytes == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                const SizedBox(height: 15),

                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ================= DETAILS =================

                buildTile("Email", profile.email),
                buildTile("Phone", profile.phone),
                buildTile("Subject", profile.subject),
                buildTile("Experience", "${profile.experience} Years"),

              ],
            ),
          );
        },
      ),
    );
  }

  // ================= INFO CARD =================

  Widget buildTile(String title, String value) {

    return Card(
      elevation: 2,

      margin: const EdgeInsets.symmetric(vertical: 6),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? "Not Provided" : value,
        ),
      ),
    );
  }
}
