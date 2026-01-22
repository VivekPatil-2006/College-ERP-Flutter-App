import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/assignment_model.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';

class EditAssignmentScreen extends StatefulWidget {

  final Assignment assignment;
  final String teacherId;

  const EditAssignmentScreen({
    super.key,
    required this.assignment,
    required this.teacherId,
  });

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  String selectedCategory = "";
  DateTime? selectedDate;

  // ✅ NEW TARGET FIELDS
  String selectedYear = "";
  String selectedDept = "";

  final FirestoreService firestoreService = FirestoreService();

  final List<String> yearList = [
    "First Year",
    "Second Year",
    "Third Year",
    "Final Year"
  ];

  final List<String> deptList = [
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

    titleController.text = widget.assignment.title;
    descController.text = widget.assignment.description;
    selectedCategory = widget.assignment.category;
    selectedDate = widget.assignment.dueDate.toDate();

    // ✅ LOAD TARGET DATA
    selectedYear = widget.assignment.targetYear;
    selectedDept = widget.assignment.targetDept;
  }

  // ================= PICK DATE =================

  Future pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= UPDATE =================

  Future updateAssignment() async {

    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    Assignment updated = Assignment(

      id: widget.assignment.id,
      teacherId: widget.assignment.teacherId,

      title: titleController.text.trim(),
      description: descController.text.trim(),
      category: selectedCategory,

      dueDate: Timestamp.fromDate(selectedDate!),
      teacherName: widget.assignment.teacherName,
      createdAt: widget.assignment.createdAt,

      // ✅ REQUIRED TARGET FIELDS
      targetYear: selectedYear,
      targetDept: selectedDept,
    );

    await firestoreService.createAssignment(
      widget.teacherId,
      updated,
    );

    // ✅ NOTIFY ONLY TARGET GROUP
    await firestoreService.sendNotification(
      AppNotification(
        title: "Assignment Updated",
        message:
        "Assignment updated for $selectedYear $selectedDept",
        role: "student",
        userId: "all",
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Assignment"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // CATEGORY
            DropdownButtonFormField<String>(
              value: selectedCategory,

              items: const [
                DropdownMenuItem(value: "Homework", child: Text("Homework")),
                DropdownMenuItem(value: "Project", child: Text("Project")),
                DropdownMenuItem(value: "Test", child: Text("Test")),
              ],

              onChanged: (value) =>
                  setState(() => selectedCategory = value!),

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Category",
              ),
            ),

            const SizedBox(height: 15),

            // TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // DESCRIPTION
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ✅ TARGET YEAR
            DropdownButtonFormField<String>(
              value: selectedYear,

              items: yearList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),

              onChanged: (val) =>
                  setState(() => selectedYear = val!),

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Target Year",
              ),
            ),

            const SizedBox(height: 15),

            // ✅ TARGET DEPARTMENT
            DropdownButtonFormField<String>(
              value: selectedDept,

              items: deptList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),

              onChanged: (val) =>
                  setState(() => selectedDept = val!),

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Target Department",
              ),
            ),

            const SizedBox(height: 15),

            // DATE
            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(selectedDate!),
                    ),

                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: updateAssignment,
                child: const Text("UPDATE ASSIGNMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
