import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/assignment_model.dart';
import 'teacher_submission_screen.dart';

class TeacherRecentSubmissionScreen extends StatelessWidget {

  const TeacherRecentSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Recent Submissions"),
        centerTitle: true,
      ),

      body: StreamBuilder<List<Assignment>>(
        stream: firestoreService.getAssignments(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var assignments = snapshot.data!;

          if (assignments.isEmpty) {
            return const Center(
              child: Text("No Assignments Available"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assignments.length,

            itemBuilder: (context, index) {

              var assignment = assignments[index];

              return StreamBuilder<int>(
                stream: firestoreService
                    .getSubmissionCountStream(
                  assignment.teacherId,
                  assignment.id,
                ),

                  builder: (context, subSnapshot) {

                  if (!subSnapshot.hasData || subSnapshot.data == 0) {
                    return const SizedBox();
                  }

                  int count = subSnapshot.data!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      elevation: 3,

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

                          child: Row(
                            children: [

                              // LEFT ICON
                              Container(
                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.blue,
                                ),
                              ),

                              const SizedBox(width: 15),

                              // TITLE + COUNT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      assignment.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "View student submissions",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // COUNT BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),

                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Row(
                                  children: [

                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.green,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
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
}
