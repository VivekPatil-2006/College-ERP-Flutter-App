import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/firestore_service.dart';
import '../../models/teacher_profile_model.dart';

class TeacherProfileEditScreen extends StatefulWidget {

  final String teacherId;

  const TeacherProfileEditScreen({super.key, required this.teacherId});

  @override
  State<TeacherProfileEditScreen> createState() =>
      _TeacherProfileEditScreenState();
}

class _TeacherProfileEditScreenState
    extends State<TeacherProfileEditScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final experienceController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  String base64Image = "";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= LOAD PROFILE =================

  void loadProfile() async {

    var profile =
    await firestoreService.getTeacherProfile(widget.teacherId);

    if (profile != null) {

      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      subjectController.text = profile.subject;
      experienceController.text = profile.experience;
      base64Image = profile.profileImage;

      setState(() {});
    }
  }

  // ================= PICK IMAGE =================

  Future pickProfileImage() async {

    final picker = ImagePicker();

    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {

      Uint8List bytes = await image.readAsBytes();

      setState(() {
        base64Image = base64Encode(bytes);
      });
    }
  }

  // ================= SAVE PROFILE =================

  void saveProfile() async {

    if (nameController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter name")),
      );
      return;
    }

    TeacherProfile profile = TeacherProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      subject: subjectController.text.trim(),
      experience: experienceController.text.trim(),
      profileImage: base64Image,
    );

    // ✅ UPDATED METHOD NAME
    await firestoreService.updateTeacherProfile(
      widget.teacherId,
      profile,
    );

    // ✅ SAFE CONTEXT USAGE
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );

    Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    Uint8List? imageBytes;

    if (base64Image.isNotEmpty) {
      imageBytes = base64Decode(base64Image);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Teacher Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // PROFILE IMAGE
            GestureDetector(
              onTap: pickProfileImage,

              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                imageBytes != null ? MemoryImage(imageBytes) : null,

                child: imageBytes == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            buildField(nameController, "Full Name"),
            buildField(emailController, "Email"),
            buildField(phoneController, "Phone"),
            buildField(subjectController, "Subject"),

            TextField(
              controller: experienceController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: "Experience (Years)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveProfile,

                child: const Text("SAVE PROFILE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INPUT FIELD
  Widget buildField(TextEditingController controller, String label) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
