import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/assignment_model.dart';
import '../../models/notification_model.dart';
import '../../services/firestore_service.dart';
import 'create_assignment_screen.dart';
import 'edit_assignment_screen.dart';
import 'teacher_submission_screen.dart';

class TeacherAssignmentScreen extends StatefulWidget {

  final String teacherId;
  final String teacherName;

  const TeacherAssignmentScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<TeacherAssignmentScreen> createState() =>
      _TeacherAssignmentScreenState();
}

class _TeacherAssignmentScreenState
    extends State<TeacherAssignmentScreen> {

  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  // ================= DELETE CONFIRM =================

  void confirmDelete(String assignmentId) {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Delete Assignment"),
        content: const Text(
          "Are you sure you want to delete this assignment?",
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

              await firestoreService.deleteAssignment(
                widget.teacherId,
                assignmentId,
              );

              // Broadcast notification
              await firestoreService.sendNotification(
                AppNotification(
                  title: "Assignment Deleted",
                  message: "An assignment was removed",
                  role: "student",
                  userId: "all",
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
        title: const Text("My Assignments"),
        centerTitle: true,

        actions: [

          // CREATE BUTTON
          IconButton(
            icon: const Icon(Icons.add_circle_outline),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateAssignmentScreen(
                    teacherId: widget.teacherId,
                    teacherName: widget.teacherName,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // ================= SEARCH =================

          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: "Search assignment title",
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: StreamBuilder<List<Assignment>>(

              stream: firestoreService
                  .getTeacherAssignments(widget.teacherId),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {

                  return const Center(
                    child: Text(
                      "No Assignments Created",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                List<Assignment> assignments = snapshot.data!;

                // SEARCH FILTER
                if (searchText.isNotEmpty) {
                  assignments = assignments.where((a) =>
                      a.title
                          .toLowerCase()
                          .contains(searchText)).toList();
                }

                return RefreshIndicator(

                  onRefresh: () async {
                    setState(() {});
                  },

                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),

                    itemCount: assignments.length,

                    itemBuilder: (context, index) {

                      final assignment = assignments[index];

                      return buildAssignmentCard(assignment);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD UI =================

  Widget buildAssignmentCard(Assignment assignment) {

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherSubmissionScreen(
                assignmentId: assignment.id,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // ================= HEADER =================

              Row(
                children: [

                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  PopupMenuButton(

                    itemBuilder: (_) => const [

                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),

                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],

                    onSelected: (value) {

                      if (value == "edit") {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditAssignmentScreen(
                                  assignment: assignment,
                                  teacherId: widget.teacherId,
                                ),
                          ),
                        );
                      }

                      if (value == "delete") {
                        confirmDelete(assignment.id);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ================= DESCRIPTION =================

              Text(
                assignment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 10),

              // ================= META ROW =================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  chip(
                    Icons.category,
                    assignment.category,
                  ),

                  chip(
                    Icons.calendar_today,
                    DateFormat("dd MMM yyyy")
                        .format(assignment.dueDate.toDate()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CHIP =================

  Widget chip(IconData icon, String text) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Icon(icon, size: 14, color: Colors.indigo),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
