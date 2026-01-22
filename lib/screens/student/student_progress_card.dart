import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class StudentProgressCard extends StatelessWidget {

  final String studentId;

  const StudentProgressCard({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return FutureBuilder<Map<String, int>>(
      future: firestoreService.getStudentProgress(studentId),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        var data = snapshot.data!;

        return Card(
          elevation: 4,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(
                  "Progress Tracker",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [

                    buildStat("Total", data["total"]!, Colors.blue),
                    buildStat("Submitted", data["submitted"]!, Colors.green),
                    buildStat("Pending", data["pending"]!, Colors.red),

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStat(String title, int value, Color color) {

    return Column(
      children: [

        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 6),

        Text(title),
      ],
    );
  }
}
