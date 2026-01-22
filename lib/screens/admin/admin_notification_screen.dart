import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';

class AdminNotificationScreen extends StatelessWidget {

  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: StreamBuilder<List<AppNotification>>(
        stream: firestoreService.getNotifications(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(child: Text("No Notifications"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {

              var notification = notifications[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(

                  leading: Icon(
                    notification.isRead
                        ? Icons.notifications
                        : Icons.notifications_active,
                    color: notification.isRead
                        ? Colors.grey
                        : Colors.red,
                  ),

                  title: Text(notification.title),
                  subtitle: Text(notification.message),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
