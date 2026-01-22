import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/student_profile_model.dart';

class AdminStudentProfileScreen extends StatelessWidget {

  final String studentId;

  const AdminStudentProfileScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),

      body: FutureBuilder<StudentProfile?>(
        future: firestoreService.getStudentProfile(studentId),

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

                buildTile("Email", profile.email),
                buildTile("Phone", profile.phone),
                buildTile("Date of Birth", profile.dob),
                buildTile("Address", profile.address),
                buildTile("Parent Name", profile.parentName),
                buildTile("Parent Contact", profile.parentContact),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTile(String title, String value) {

    return Card(
      elevation: 2,

      margin: const EdgeInsets.symmetric(vertical: 6),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? "Not Provided" : value),
      ),
    );
  }
}
