import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/firestore_service.dart';
import '../../models/student_profile_model.dart';
import '../../models/notification_model.dart';

class StudentProfileScreen extends StatefulWidget {

  final String userId;

  const StudentProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentContactController = TextEditingController();

  String base64Image = "";

  // ✅ NEW DROPDOWN VALUES
  String selectedYear = "First Year";
  String selectedDepartment = "IT";

  final FirestoreService firestoreService = FirestoreService();

  final List<String> yearList = [
    "First Year",
    "Second Year",
    "Third Year",
    "Final Year"
  ];

  final List<String> departmentList = [
    "IT",
    "Computer",
    "ENTC",
    "Mechanical",
    "Civil",
    "Electrical"
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= LOAD PROFILE =================

  void loadProfile() async {

    final profile =
    await firestoreService.getStudentProfile(widget.userId);

    if (profile != null) {

      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      dobController.text = profile.dob;
      addressController.text = profile.address;
      parentNameController.text = profile.parentName;
      parentContactController.text = profile.parentContact;
      base64Image = profile.profileImage;

      // ✅ LOAD YEAR + DEPARTMENT
      selectedYear = profile.year.isEmpty
          ? selectedYear
          : profile.year;

      selectedDepartment = profile.department.isEmpty
          ? selectedDepartment
          : profile.department;

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

  // ================= DATE PICKER =================

  Future pickDOB() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (picked != null) {

      setState(() {
        dobController.text =
        "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  // ================= SAVE PROFILE =================

  void saveProfile() async {

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Name")),
      );
      return;
    }

    StudentProfile profile = StudentProfile(

      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      dob: dobController.text.trim(),
      address: addressController.text.trim(),

      parentName: parentNameController.text.trim(),
      parentContact: parentContactController.text.trim(),

      profileImage: base64Image,

      // ✅ REQUIRED FIELDS ADDED
      year: selectedYear,
      department: selectedDepartment,
    );

    await firestoreService.updateStudentProfile(
      widget.userId,
      profile,
    );

    await firestoreService.sendNotification(
      AppNotification(
        title: "Profile Updated",
        message: "Your profile was updated successfully",
        role: "student",
        userId: widget.userId,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully")),
    );
  }

  // ================= RANDOM AVATAR =================

  String getRandomAvatar() {
    return
      "https://api.dicebear.com/7.x/personas/png?seed=${widget.userId}";
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ===== PROFILE HEADER =====

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

              child: Center(
                child: Stack(
                  children: [

                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,

                      backgroundImage: base64Image.isNotEmpty
                          ? MemoryImage(base64Decode(base64Image))
                          : NetworkImage(getRandomAvatar())
                      as ImageProvider,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,

                      child: GestureDetector(
                        onTap: pickProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  sectionTitle("Student Details"),

                  buildCard([

                    buildField(nameController, "Full Name"),
                    buildField(emailController, "Email"),
                    buildField(phoneController, "Phone"),

                    GestureDetector(
                      onTap: pickDOB,
                      child: AbsorbPointer(
                        child: buildField(
                            dobController, "Date of Birth"),
                      ),
                    ),

                    buildField(addressController, "Address"),

                    // ✅ YEAR DROPDOWN
                    buildDropdown(
                      "Year",
                      selectedYear,
                      yearList,
                          (val) => setState(() => selectedYear = val),
                    ),

                    // ✅ DEPARTMENT DROPDOWN
                    buildDropdown(
                      "Department",
                      selectedDepartment,
                      departmentList,
                          (val) => setState(() => selectedDepartment = val),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  sectionTitle("Parent Details"),

                  buildCard([
                    buildField(parentNameController, "Parent Name"),
                    buildField(parentContactController, "Parent Contact"),
                  ]),

                  const SizedBox(height: 25),

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

          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget sectionTitle(String text) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildCard(List<Widget> children) {

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: children),
      ),
    );
  }

  Widget buildField(TextEditingController controller, String label) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ✅ DROPDOWN BUILDER
  Widget buildDropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged,
      ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(

        value: value,

        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),

        onChanged: (val) => onChanged(val!),

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
