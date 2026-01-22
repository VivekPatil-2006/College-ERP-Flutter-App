import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';
import '../../services/cloudinary_service.dart';
import '../../services/email_service.dart';

class SubmitAssignmentScreen extends StatefulWidget {

  final String assignmentId;
  final String studentId;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignmentId,
    required this.studentId,
  });

  @override
  State<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {

  final TextEditingController answerController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  File? selectedFile;
  String uploadedFileUrl = "";

  bool isUploading = false;
  bool isSubmitting = false;

  // ================= PICK FILE =================

  Future pickFile() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {

      File file = File(result.files.single.path!);

      // MAX FILE SIZE = 10MB
      if (file.lengthSync() > 10 * 1024 * 1024) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File size must be under 10MB")),
        );

        return;
      }

      setState(() {
        selectedFile = file;
        uploadedFileUrl = "";
      });
    }
  }

  // ================= UPLOAD =================

  Future uploadFile() async {

    if (selectedFile == null) return;

    setState(() => isUploading = true);

    try {

      String? url =
      await CloudinaryService.uploadFile(selectedFile!);

      if (url != null) {

        uploadedFileUrl = url;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File Uploaded Successfully")),
        );

      } else {

        throw "Upload Failed";
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Failed")),
      );
    }

    setState(() => isUploading = false);
  }

  // ================= SUBMIT =================

  Future submitAssignment() async {

    if (answerController.text.trim().isEmpty &&
        uploadedFileUrl.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add answer or attach file"),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {

      // ================= SAVE SUBMISSION =================

      await firestoreService.submitAssignmentWithFile(
        widget.assignmentId,
        widget.studentId,
        answerController.text.trim(),
        uploadedFileUrl,
      );

      // ================= FETCH TEACHER EMAIL =================

      final teacherData =
      await firestoreService.getTeacherEmailByAssignment(
        widget.assignmentId,
      );

      // ================= SEND EMAIL =================

      await EmailService.sendSubmissionMail(
        teacherEmail: teacherData['email']!,
        teacherName: teacherData['name']!,
        assignmentTitle: teacherData['title']!,
        studentId: widget.studentId,
      );

      // ================= STUDENT NOTIFICATION =================

      await firestoreService.sendNotification(
        AppNotification(
          title: "Assignment Submitted",
          message: "Your assignment was submitted successfully",
          role: "student",
          userId: widget.studentId,
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission Failed")),
      );
    }

    setState(() => isSubmitting = false);
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Submit Assignment"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // ANSWER BOX
            TextField(
              controller: answerController,
              maxLines: 5,

              decoration: InputDecoration(
                labelText: "Write your answer",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // FILE SELECT CARD
            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_file),

                title: Text(
                  selectedFile == null
                      ? "Attach File"
                      : selectedFile!.path.split('/').last,
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: pickFile,
                    ),

                    if (selectedFile != null)

                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                            uploadedFileUrl = "";
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // UPLOAD BUTTON
            if (selectedFile != null && uploadedFileUrl.isEmpty)

              SizedBox(
                width: double.infinity,
                height: 45,

                child: ElevatedButton(
                  onPressed: isUploading ? null : uploadFile,

                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("UPLOAD FILE"),
                ),
              ),

            const SizedBox(height: 10),

            // UPLOAD STATUS
            if (uploadedFileUrl.isNotEmpty)

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: const Row(
                  children: [

                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text("File Uploaded Successfully"),

                  ],
                ),
              ),

            const SizedBox(height: 20),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitAssignment,

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SUBMIT ASSIGNMENT"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
