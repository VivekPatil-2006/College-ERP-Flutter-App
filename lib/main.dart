import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_student_list_screen.dart';
import 'screens/admin/admin_teacher_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Teacher Portal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
      routes: {
        '/adminStudents': (context) => const AdminStudentListScreen(),
        '/adminTeachers': (context) => const AdminTeacherListScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Student Teacher Portal",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
