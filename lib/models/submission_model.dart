import 'package:cloud_firestore/cloud_firestore.dart';

class Submission {

  final String id;
  final String assignmentId;
  final String studentId;
  final String answer;
  final String fileUrl;
  final String feedback;
  final Timestamp submittedAt;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.answer,
    required this.fileUrl,
    required this.feedback,
    required this.submittedAt,
  });

  factory Submission.fromMap(
      Map<String, dynamic> map,
      String docId,
      ) {

    return Submission(
      id: docId,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      answer: map['answer'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      feedback: map['feedback'] ?? '',
      submittedAt: map['submittedAt'] is Timestamp
          ? map['submittedAt']
          : Timestamp.now(), // safety fallback
    );
  }
}
