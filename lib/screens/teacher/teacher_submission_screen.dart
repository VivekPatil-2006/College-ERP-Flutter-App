import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firestore_service.dart';
import '../../models/submission_model.dart';
import 'give_feedback_screen.dart';

class TeacherSubmissionScreen extends StatelessWidget {

  final String assignmentId;

  const TeacherSubmissionScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Student Submissions"),
        centerTitle: true,
      ),

      body: FutureBuilder<int>(
        future: firestoreService.getStudentCount(),

        builder: (context, studentSnapshot) {

          if (!studentSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalStudents = studentSnapshot.data!;

          return StreamBuilder<List<Submission>>(
            stream: firestoreService.getSubmissions(assignmentId),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var submissions = snapshot.data!;
              int submittedCount = submissions.length;
              int pendingCount = totalStudents - submittedCount;

              return Column(
                children: [

                  // ================= SUMMARY CARDS =================

                  Padding(
                    padding: const EdgeInsets.all(12),

                    child: Row(
                      children: [

                        summaryCard(
                          Icons.check_circle,
                          "Submitted",
                          submittedCount,
                          Colors.green,
                        ),

                        const SizedBox(width: 10),

                        summaryCard(
                          Icons.pending_actions,
                          "Pending",
                          pendingCount,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  // ================= LIST =================

                  Expanded(
                    child: submissions.isEmpty

                        ? const Center(
                      child: Text(
                        "No submissions yet",
                        style: TextStyle(fontSize: 16),
                      ),
                    )

                        : ListView.builder(
                      padding: const EdgeInsets.all(10),

                      itemCount: submissions.length,

                      itemBuilder: (context, index) {

                        var submission = submissions[index];
                        bool reviewed = submission.feedback.isNotEmpty;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),

                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,

                            child: Padding(
                              padding: const EdgeInsets.all(14),

                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  // ================= STUDENT HEADER =================

                                  Row(
                                    children: [

                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor:
                                        Colors.blue.shade100,

                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          submission.studentId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),

                                      // REVIEW STATUS BADGE
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),

                                        decoration: BoxDecoration(
                                          color: reviewed
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),

                                        child: Text(
                                          reviewed
                                              ? "Reviewed"
                                              : "Pending Review",

                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: reviewed
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // ================= ANSWER =================

                                  Text(
                                    submission.answer.isEmpty
                                        ? "No text answer submitted"
                                        : submission.answer,

                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // ================= FILE ATTACHMENT =================

                                  if (submission.fileUrl.isNotEmpty)

                                    Container(
                                      padding: const EdgeInsets.all(10),

                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),

                                      child: Row(
                                        children: [

                                          const Icon(
                                            Icons.attach_file,
                                            color: Colors.blue,
                                          ),

                                          const SizedBox(width: 8),

                                          const Text(
                                            "Attachment Available",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const Spacer(),

                                          IconButton(
                                            icon: const Icon(Icons.download),

                                            onPressed: () async {

                                              final uri = Uri.parse(
                                                  submission.fileUrl);

                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 12),

                                  // ================= FEEDBACK BUTTON =================

                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,

                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.rate_review),
                                      label: const Text("Give Feedback"),

                                      style: ElevatedButton.styleFrom(
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),

                                      onPressed: () {

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                GiveFeedbackScreen(
                                                  submissionId:
                                                  submission.id,
                                                  studentId:
                                                  submission.studentId,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget summaryCard(
      IconData icon,
      String title,
      int count,
      Color color,
      ) {

    return Expanded(
      child: Card(
        elevation: 3,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            children: [

              Icon(icon, color: color),

              const SizedBox(height: 6),

              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
