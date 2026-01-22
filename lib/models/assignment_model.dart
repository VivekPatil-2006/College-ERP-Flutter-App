import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {

  final String id;
  final String teacherId;   // ✅ REQUIRED
  final String title;
  final String description;
  final String category;
  final Timestamp dueDate;
  final String teacherName;
  final Timestamp createdAt;
  final String targetYear;
  final String targetDept;


  Assignment({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.teacherName,
    required this.createdAt,
    required this.targetYear,
    required this.targetDept,
  });

  // ================= TO MAP =================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId, // ✅ STORE
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate,
      'teacherName': teacherName,
      'createdAt': createdAt,
      'targetYear': targetYear,
      'targetDept': targetDept,
    };
  }

  // ================= FROM MAP =================

  factory Assignment.fromMap(Map<String, dynamic> map) {

    return Assignment(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',   // ✅ READ
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: map['dueDate'] ?? Timestamp.now(),
      teacherName: map['teacherName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      targetYear: map['targetYear'] ?? '',
      targetDept: map['targetDept'] ?? '',
    );
  }
}
