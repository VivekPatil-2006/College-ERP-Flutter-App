import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firestore_service.dart';
import '../../models/assignment_model.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentScreen extends StatelessWidget {

  final String studentId;

  const StudentAssignmentScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {

    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: StreamBuilder<List<Assignment>>(
        stream: firestoreService.getAssignments(),

        builder: (context, assignmentSnap) {

          if (assignmentSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!assignmentSnap.hasData || assignmentSnap.data!.isEmpty) {
            return const Center(child: Text("No Assignments Available"));
          }

          final assignments = assignmentSnap.data!;

          // ================= STUDENT SUBMISSION MAP =================

          return StreamBuilder<Map<String, Map<String, dynamic>>>(
            stream: firestoreService.getStudentSubmissionsMap(studentId),

            builder: (context, submissionSnap) {

              final submissionMap = submissionSnap.data ?? {};

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: assignments.length,

                itemBuilder: (context, index) {

                  final assignment = assignments[index];

                  final isSubmitted =
                  submissionMap.containsKey(assignment.id);

                  final submittedFile =
                      submissionMap[assignment.id]?['fileUrl'] ?? '';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(14),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ================= TITLE =================

                          Text(
                            assignment.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ================= DETAILS =================

                          infoRow("Subject", assignment.category),

                          infoRow(
                            "Due Date",
                            assignment.dueDate
                                .toDate()
                                .toString()
                                .substring(0, 10),
                          ),

                          infoRow("Teacher", assignment.teacherName),

                          const SizedBox(height: 8),

                          Text(
                            assignment.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ================= STATUS ROW =================

                          Row(
                            children: [

                              statusChip(isSubmitted),

                              const Spacer(),

                              // DOWNLOAD FILE
                              if (isSubmitted && submittedFile.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () async {

                                    final uri = Uri.parse(submittedFile);

                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),

                              // SUBMIT BUTTON
                              if (!isSubmitted)
                                ElevatedButton(
                                  onPressed: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SubmitAssignmentScreen(
                                              assignmentId: assignment.id,
                                              studentId: studentId,
                                            ),
                                      ),
                                    );
                                  },

                                  child: const Text("Submit"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget statusChip(bool submitted) {

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: submitted
            ? Colors.green.shade100
            : Colors.orange.shade100,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        submitted ? "SUBMITTED" : "PENDING",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: submitted ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  // ================= INFO ROW =================

  Widget infoRow(String title, String value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Row(
        children: [

          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
