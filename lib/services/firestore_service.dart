import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_student_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../models/student_profile_model.dart';
import '../models/teacher_profile_model.dart';
import '../models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirestoreService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // ================= ASSIGNMENTS =================

  Future createAssignment(String teacherId, Assignment assignment) async {
    await _db
        .collection("assignments")
        .doc(assignment.id)
        .set(assignment.toMap());
  }

  Stream<List<Assignment>> getAssignments() {
    return _db
        .collection("assignments")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            Assignment.fromMap(doc.data())).toList());
  }

  Stream<List<Assignment>> getTeacherAssignments(String teacherId) {
    return _db
        .collection("assignments")
        .where("teacherId", isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            Assignment.fromMap(doc.data())).toList());
  }

  Future deleteAssignment(String teacherId, String assignmentId) async {
    await _db.collection("assignments").doc(assignmentId).delete();
  }

  // ================= SUBMISSIONS =================

  Future submitAssignment(
      String assignmentId,
      String studentId,
      String answer,
      String fileUrl,
      ) async {

    String docId = "${assignmentId}_$studentId";

    await _db.collection("submissions").doc(docId).set({
      "assignmentId": assignmentId,
      "studentId": studentId,
      "answer": answer,
      "fileUrl": fileUrl,
      "feedback": "",
      "submittedAt": Timestamp.now(),
    });
  }

  Stream<List<Submission>> getSubmissions(String assignmentId) {
    return _db
        .collection("submissions")
        .where("assignmentId", isEqualTo: assignmentId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) =>
            Submission.fromMap(doc.data(), doc.id)).toList());
  }

  Future<Map<String, dynamic>?> getStudentSubmission(
      String assignmentId,
      String studentId,
      ) async {

    String id = "${assignmentId}_$studentId";

    var doc =
    await _db.collection("submissions").doc(id).get();

    return doc.exists ? doc.data() : null;
  }

  Future addFeedback(
      String submissionId,
      String feedback,
      String studentId,
      ) async {

    await _db
        .collection("submissions")
        .doc(submissionId)
        .update({
      "feedback": feedback,
    });

    // Notify only that student
    await sendNotification(
      AppNotification(
        title: "Assignment Reviewed",
        message: "Teacher has reviewed your submission",
        role: "student",
        userId: studentId,
      ),
    );
  }


  Stream<List<Assignment>> getStudentAssignments(
      String year,
      String dept,
      ) {

    return _db
        .collection("assignments")
        .where("targetYear", isEqualTo: year)
        .where("targetDept", isEqualTo: dept)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            Assignment.fromMap(doc.data())).toList());
  }


  // ================= PROGRESS =================

  Future<Map<String, int>> getStudentProgress(String studentId) async {

    var totalAssignments =
    await _db.collection("assignments").get();

    var submitted =
    await _db.collection("submissions")
        .where("studentId", isEqualTo: studentId)
        .get();

    int total = totalAssignments.size;
    int done = submitted.size;

    return {
      "total": total,
      "submitted": done,
      "pending": total - done,
    };
  }

  // ================= PROFILES =================

  Future<StudentProfile?> getStudentProfile(String uid) async {

    var doc = await _db
        .collection('users')
        .doc('students')
        .collection('data')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return StudentProfile.fromMap(doc.data()!);
  }


  Future updateStudentProfile(String uid, StudentProfile profile) async {

    await _db
        .collection('users')
        .doc('students')
        .collection('data')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  // ================= SUBMIT ASSIGNMENT WITH FILE =================

  Future<void> submitAssignmentWithFile(
      String assignmentId,
      String studentId,
      String answer,
      String fileUrl,
      ) async {

    String docId = "${assignmentId}_$studentId";

    await _db
        .collection("submissions")
        .doc(docId)
        .set({

      "assignmentId": assignmentId,
      "studentId": studentId,
      "answer": answer,
      "fileUrl": fileUrl,
      "feedback": "",
      "submittedAt": FieldValue.serverTimestamp(),

    });
  }

  // ================= ASSIGNMENT ANALYTICS =================

  Future<Map<String, int>> getAssignmentAnalytics(
      String teacherId,
      String assignmentId,
      ) async {

    // Total students count
    final studentsSnapshot =
    await _db.collection("students").get();

    int totalStudents = studentsSnapshot.size;

    // Submitted count for this assignment
    final submittedSnapshot = await _db
        .collection("submissions")
        .where("assignmentId", isEqualTo: assignmentId)
        .get();

    int submittedCount = submittedSnapshot.size;

    return {
      "total": totalStudents,
      "submitted": submittedCount,
      "pending": totalStudents - submittedCount,
    };
  }

  // ================= SUBMISSION COUNT STREAM =================

  Stream<int> getSubmissionCountStream(
      String teacherId,
      String assignmentId,
      ) {

    return _db
        .collection("submissions")
        .where("assignmentId", isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // ================= STUDENT COUNT =================

  Future<int> getStudentCount() async {

    final snapshot = await _db.collection("students").get();

    return snapshot.size;
  }






  Future<TeacherProfile?> getTeacherProfile(String uid) async {

    var doc = await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return TeacherProfile.fromMap(doc.data()!);
  }


  Future updateTeacherProfile(String uid, TeacherProfile profile) async {

    await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }


  // ================= NOTIFICATIONS =================

  Future sendNotification(AppNotification notification) async {

    await _db.collection("notifications").add({

      'title': notification.title,
      'message': notification.message,
      'role': notification.role,
      'userId': notification.userId,
      'isRead': false,

      // IMPORTANT
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<List<AppNotification>> getNotifications() {

    return _db
        .collection("notifications")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) =>
            AppNotification.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<Map<String, Map<String, dynamic>>> getStudentSubmissionsMap(String studentId) {

    return FirebaseFirestore.instance
        .collection('submissions')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {

      Map<String, Map<String, dynamic>> map = {};

      for (var doc in snapshot.docs) {
        map[doc['assignmentId']] = doc.data();
      }

      return map;
    });
  }

  Stream<List<AppNotification>> getUserNotifications(String userId) {

    return _db
        .collection('notifications')

    // ONLY FILTER USER
        .where('userId', whereIn: [userId, 'all'])

    // DO NOT ORDER HERE (avoid index crash)
        .snapshots()

        .map((snapshot) {

      final list = snapshot.docs.map((doc) {

        return AppNotification.fromMap(
          doc.data(),
          doc.id,
        );

      }).toList();

      // SORT SAFELY IN APP
      list.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt));

      return list;
    });
  }

  Future<void> markNotificationRead(String notificationId) async {

    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({

      'isRead': true,
    });
  }


  Future<void> sendAssignmentNotificationToTargetStudents(
      String year,
      String dept,
      String title,
      ) async {

    final students = await _db
        .collection("students")
        .where("year", isEqualTo: year)
        .where("department", isEqualTo: dept)
        .get();

    for (var doc in students.docs) {

      await _db.collection("notifications").add({

        "title": title,
        "message": "New assignment available",
        "role": "student",
        "userId": doc.id, // individual user
        "isRead": false,
        "createdAt": Timestamp.now(),
      });
    }
  }


  Stream<int> getUnreadNotificationCount(String userId) {

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', whereIn: [userId, 'all'])
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ================= ADMIN ANNOUNCEMENT =================

  Future<void> sendAnnouncement(String title, String message) async {

    await _db.collection("notifications").add({

      "title": title,
      "message": message,
      "role": "student",
      "userId": "all",
      "isRead": false,

      // USE THIS
      "createdAt": Timestamp.now(),
    });
  }

  Future<Map<String, String>> getTeacherEmailByAssignment(
      String assignmentId,
      ) async {

    // Fetch assignment
    final assignmentDoc =
    await _db.collection("assignments").doc(assignmentId).get();

    final teacherId = assignmentDoc['teacherId'];
    final assignmentTitle = assignmentDoc['title'];

    // Fetch teacher profile
    final teacherDoc = await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .doc(teacherId)
        .get();

    final teacherEmail = teacherDoc['email'];
    final teacherName = teacherDoc['name'];

    return {
      "email": teacherEmail,
      "name": teacherName,
      "title": assignmentTitle,
    };
  }



  // ================= ADMIN STUDENT LIST =================

  Stream<QuerySnapshot> getStudentsStream() {

    return _db
        .collection('users')
        .doc('students')
        .collection('data')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteStudent(String uid) async {

    await _db
        .collection('users')
        .doc('students')
        .collection('data')
        .doc(uid)
        .delete();
  }

  // ================= ADMIN TEACHERS =================

  Future<List<AdminStudent>> getTeachers({int limit = 10}) async {

    final snapshot = await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) =>
        AdminStudent.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<AdminStudent>> searchTeachers(String keyword) async {

    final snapshot = await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .get();

    return snapshot.docs
        .map((doc) =>
        AdminStudent.fromMap(doc.id, doc.data()))
        .where((teacher) =>
    teacher.name.toLowerCase().contains(keyword.toLowerCase()) ||
        teacher.email.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Future<void> deleteTeacher(String teacherId) async {

    await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .doc(teacherId)
        .delete();
  }

  // ================= AUTH LOGIN =================

  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password,
      ) async {

    try {

      // FIREBASE AUTH LOGIN
      UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;

      // CHECK STUDENT COLLECTION
      final studentDoc = await _db
          .collection('users')
          .doc('students')
          .collection('data')
          .doc(uid)
          .get();

      if (studentDoc.exists) {
        return {
          "role": "student",
          "uid": uid,
        };
      }

      // CHECK TEACHER COLLECTION
      final teacherDoc = await _db
          .collection('users')
          .doc('teachers')
          .collection('data')
          .doc(uid)
          .get();

      if (teacherDoc.exists) {
        return {
          "role": "teacher",
          "uid": uid,
        };
      }

      // NO ROLE FOUND
      return null;

    } catch (e) {

      print("LOGIN ERROR: $e");
      return null;
    }
  }

  // ================= REGISTER STUDENT =================

  Future<void> createStudent(AppUser user) async {

    await _db
        .collection('users')
        .doc('students')
        .collection('data')
        .doc(user.id)
        .set({

      'name': user.name,
      'email': user.email,
      'phone': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= REGISTER TEACHER =================

  Future<void> createTeacher(AppUser user) async {

    await _db
        .collection('users')
        .doc('teachers')
        .collection('data')
        .doc(user.id)
        .set({

      'name': user.name,
      'email': user.email,
      'phone': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }





  // ================= ADMIN COUNTS =================

  Stream<int> getStudentCountStream() =>
      _db
          .collection('users')
          .doc('students')
          .collection('data')
          .snapshots()
          .map((s) => s.size);


  Stream<int> getTeacherCountStream() =>
      _db
          .collection('users')
          .doc('teachers')
          .collection('data')
          .snapshots()
          .map((s) => s.size);


  Stream<int> getAssignmentCountStream() =>
      _db.collection("assignments").snapshots().map((s) => s.size);

  Stream<int> getTotalSubmissionCountStream() =>
      _db.collection("submissions").snapshots().map((s) => s.size);

}
