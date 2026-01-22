import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {

  final String id;
  final String title;
  final String message;
  final String role;
  final String userId;

  final bool isRead;
  final Timestamp createdAt;

  AppNotification({
    this.id = '',
    required this.title,
    required this.message,
    required this.role,
    required this.userId,
    this.isRead = false,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  // ================= TO MAP =================

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'role': role,
      'userId': userId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  // ================= FROM MAP =================

  factory AppNotification.fromMap(
      Map<String, dynamic> map,
      String docId,
      ) {

    return AppNotification(

      id: docId,

      title: map['title'] ?? '',
      message: map['message'] ?? '',
      role: map['role'] ?? '',
      userId: map['userId'] ?? '',

      isRead: map['isRead'] ?? false,

      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
