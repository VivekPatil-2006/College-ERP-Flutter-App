import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {

  // ================= EMAILJS CONFIG =================

  static const String serviceId = "service_gkunkzf";
  static const String templateId = "template_eq6bs0t";
  static const String publicKey = "3xaIopP3rpXlYM_kA";

  static Future<bool> sendSubmissionMail({
    required String teacherEmail,
    required String teacherName,
    required String assignmentTitle,
    required String studentId,
  }) async {

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "origin": "http://localhost",
      },
      body: jsonEncode({

        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,

        "template_params": {
          "teacher_email": teacherEmail,
          "teacher_name": teacherName,
          "assignment_title": assignmentTitle,
          "student_id": studentId,
          "time": DateTime.now().toString(),
        }
      }),
    );

    return response.statusCode == 200;
  }
}
