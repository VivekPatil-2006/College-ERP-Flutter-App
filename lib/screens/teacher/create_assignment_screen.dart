import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/assignment_model.dart';
import '../../models/notification_model.dart';
import '../../services/firestore_service.dart';

class CreateAssignmentScreen extends StatefulWidget {

  final String teacherId;
  final String teacherName;

  const CreateAssignmentScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();
  String selectedYear = "Third Year";
  String selectedDept = "IT";


  String selectedCategory = "Homework";
  DateTime? selectedDate;

  final FirestoreService firestoreService = FirestoreService();

  // ================= DATE PICKER =================

  Future pickDueDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= CREATE ASSIGNMENT =================

  Future createAssignment() async {

    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        selectedDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    String assignmentId =
        FirebaseFirestore.instance.collection("assignments").doc().id;

    Assignment assignment = Assignment(
      id: assignmentId,
      teacherId: widget.teacherId,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      category: selectedCategory,
      dueDate: Timestamp.fromDate(selectedDate!),
      teacherName: widget.teacherName,
      targetYear: selectedYear,          // ✅
      targetDept: selectedDept,          // ✅
      createdAt: Timestamp.now(),
    );


    // ✅ SAVE ASSIGNMENT
    await firestoreService.createAssignment(
      widget.teacherId,
      assignment,
    );
    await firestoreService.sendAssignmentNotificationToTargetStudents(
      selectedYear,
      selectedDept,
      "New Assignment Posted",
    );



    // ✅ SEND BROADCAST NOTIFICATION TO STUDENTS
    await firestoreService.sendNotification(
      AppNotification(
        title: "New Assignment Posted",
        message: "A new assignment has been added",
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
        title: const Text("Create Assignment"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedYear,
              items: const [
                DropdownMenuItem(value: "First Year", child: Text("First Year")),
                DropdownMenuItem(value: "Second Year", child: Text("Second Year")),
                DropdownMenuItem(value: "Third Year", child: Text("Third Year")),
                DropdownMenuItem(value: "Final Year", child: Text("Final Year")),
              ],
              onChanged: (value) {
                setState(() => selectedYear = value!);
              },
              decoration: const InputDecoration(
                labelText: "Target Year",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedDept,
              items: const [
                DropdownMenuItem(value: "IT", child: Text("IT")),
                DropdownMenuItem(value: "CS", child: Text("CS")),
                DropdownMenuItem(value: "ENTC", child: Text("ENTC")),
                DropdownMenuItem(value: "MECH", child: Text("MECH")),
              ],
              onChanged: (value) {
                setState(() => selectedDept = value!);
              },
              decoration: const InputDecoration(
                labelText: "Target Department",
                border: OutlineInputBorder(),
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,

              items: const [
                DropdownMenuItem(value: "Homework", child: Text("Homework")),
                DropdownMenuItem(value: "Project", child: Text("Project")),
                DropdownMenuItem(value: "Test", child: Text("Test")),
              ],

              onChanged: (value) =>
                  setState(() => selectedCategory = value!),

              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickDueDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      selectedDate == null
                          ? "Select Due Date"
                          : DateFormat('dd MMM yyyy')
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
                onPressed: createAssignment,
                child: const Text("CREATE ASSIGNMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
