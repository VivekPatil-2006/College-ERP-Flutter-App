import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';

class StudentNotificationScreen extends StatelessWidget {

  final String studentId;

  const StudentNotificationScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Column(
        children: [

          // ================= HEADER =================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blue],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),

            child: const Center(
              child: Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: StreamBuilder<List<AppNotification>>(

              stream: firestoreService.getUserNotifications(studentId),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error loading notifications"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [

                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "No Notifications",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }

                final notifications = snapshot.data!;

                return ListView.builder(

                  padding: const EdgeInsets.all(12),

                  itemCount: notifications.length,

                  itemBuilder: (context, index) {

                    final notification = notifications[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: ListTile(

                        onTap: () async {

                          if (!notification.isRead) {

                            await firestoreService
                                .markNotificationRead(notification.id);
                          }
                        },

                        leading: CircleAvatar(
                          backgroundColor: notification.isRead
                              ? Colors.grey.shade200
                              : Colors.indigo.shade100,

                          child: Icon(
                            Icons.notifications,
                            color: notification.isRead
                                ? Colors.grey
                                : Colors.indigo,
                          ),
                        ),

                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notification.isRead
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),

                        subtitle: Text(
                          notification.message,
                          style: TextStyle(
                            color: notification.isRead
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),

                        trailing: notification.isRead
                            ? null
                            : Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
