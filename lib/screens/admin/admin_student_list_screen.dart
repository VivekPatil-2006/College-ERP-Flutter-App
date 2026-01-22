import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firestore_service.dart';
import '../../models/admin_student_model.dart';
import 'admin_student_profile_screen.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

  @override
  State<AdminStudentListScreen> createState() =>
      _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {

  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  // ================= DELETE CONFIRM =================

  void confirmDelete(AdminStudent student) {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text(
          "Are you sure you want to remove ${student.name}?",
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),

            onPressed: () async {

              Navigator.pop(context);

              await firestoreService.deleteStudent(student.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Student Deleted"),
                ),
              );
            },

            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Student Management"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ================= SEARCH BAR =================

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),

            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(30),

              child: TextField(
                controller: searchController,

                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  hintText: "Search by name or email",
                  prefixIcon: const Icon(Icons.search),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ================= STUDENT LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: firestoreService.getStudentsStream(),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {

                  return emptyState();
                }

                // Convert to Model
                List<AdminStudent> students =
                snapshot.data!.docs.map((doc) {

                  return AdminStudent.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );

                }).toList();

                // SEARCH FILTER
                if (searchText.isNotEmpty) {

                  students = students.where((s) =>
                  s.name.toLowerCase().contains(searchText) ||
                      s.email.toLowerCase().contains(searchText))
                      .toList();
                }

                if (students.isEmpty) {
                  return emptyState();
                }

                return Column(
                  children: [

                    // ================= TOTAL COUNT =================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),

                      child: Row(
                        children: [

                          const Icon(Icons.people, size: 18),

                          const SizedBox(width: 6),

                          Text(
                            "Total Students: ${students.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= LIST =================

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),

                        itemCount: students.length,

                        itemBuilder: (context, index) {

                          final student = students[index];

                          return Dismissible(

                            key: ValueKey(student.id),
                            direction: DismissDirection.endToStart,

                            background: Container(
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,

                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            confirmDismiss: (_) async {

                              confirmDelete(student);
                              return false;
                            },

                            child: studentCard(student),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= STUDENT CARD =================

  Widget studentCard(AdminStudent student) {

    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(

        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: CircleAvatar(
          radius: 22,

          backgroundColor: Colors.indigo.shade100,

          child: Text(
            student.name.isNotEmpty
                ? student.name[0].toUpperCase()
                : "?",

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),

        title: Text(
          student.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        subtitle: Text(
          student.email,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminStudentProfileScreen(
                    studentId: student.id,
                  ),
            ),
          );
        },
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget emptyState() {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.people_outline,
            size: 90,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          Text(
            "No Students Found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
