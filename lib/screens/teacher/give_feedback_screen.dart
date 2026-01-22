import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class GiveFeedbackScreen extends StatefulWidget {

  final String submissionId;
  final String studentId;

  const GiveFeedbackScreen({
    super.key,
    required this.submissionId,
    required this.studentId,
  });

  @override
  State<GiveFeedbackScreen> createState() =>
      _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {

  final TextEditingController feedbackController =
  TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  bool isSaving = false;

  Future submitFeedback() async {

    if (feedbackController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter feedback")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await firestoreService.addFeedback(
      widget.submissionId,
      feedbackController.text.trim(),
      widget.studentId,
    );

    setState(() {
      isSaving = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Give Feedback"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: feedbackController,
              maxLines: 5,

              decoration: const InputDecoration(
                labelText: "Write Feedback",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                onPressed: isSaving ? null : submitFeedback,

                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SEND FEEDBACK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
