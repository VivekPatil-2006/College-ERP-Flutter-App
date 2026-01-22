import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AdminAnnouncementScreen extends StatefulWidget {

  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  bool isSending = false;

  // ================= SEND ANNOUNCEMENT =================

  Future sendAnnouncement() async {

    String title = titleController.text.trim();
    String message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isSending = true);

    await firestoreService.sendAnnouncement(title, message);

    setState(() => isSending = false);

    titleController.clear();
    messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Announcement Sent Successfully")),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Admin Announcement"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // TITLE
            TextField(
              controller: titleController,

              decoration: InputDecoration(
                labelText: "Announcement Title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // MESSAGE
            TextField(
              controller: messageController,
              maxLines: 5,

              decoration: InputDecoration(
                labelText: "Announcement Message",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),

                onPressed: isSending ? null : sendAnnouncement,

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                label: isSending
                    ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                    : const Text("SEND ANNOUNCEMENT"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
