import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class AssignmentAnalyticsCard extends StatelessWidget {

  final String teacherId;
  final String assignmentId;
  final String title;
  final String category;
  final DateTime dueDate;

  const AssignmentAnalyticsCard({
    super.key,
    required this.teacherId,
    required this.assignmentId,
    required this.title,
    required this.category,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return FutureBuilder<Map<String, int>>(
      future: firestoreService.getAssignmentAnalytics(
        teacherId,
        assignmentId,
      ),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!;

        int total = data["total"]!;
        int submitted = data["submitted"]!;
        int pending = data["pending"]!;

        double progress =
        total == 0 ? 0 : (submitted / total);

        bool isOverdue = DateTime.now().isAfter(dueDate);

        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ================= HEADER =================

                Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.assignment,
                        color: Colors.indigo,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [

                              // CATEGORY CHIP
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // DUE DATE
                              Text(
                                "Due: ${DateFormat('dd MMM').format(dueDate)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOverdue
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 15),

                // ================= STATS =================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [

                    buildStat("Total", total, Colors.blue),
                    buildStat("Submitted", submitted, Colors.green),
                    buildStat("Pending", pending, Colors.red),

                  ],
                ),

                const SizedBox(height: 14),

                // ================= PROGRESS BAR =================

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,

                  child: Text(
                    "${(progress * 100).toStringAsFixed(0)}% Completed",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= STAT ITEM =================

  Widget buildStat(String label, int value, Color color) {

    return Column(
      children: [

        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
