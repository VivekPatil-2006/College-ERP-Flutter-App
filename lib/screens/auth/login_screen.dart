import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  bool isPasswordHidden = true;

  void login() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // ADMIN STATIC LOGIN
    if (email == "admin@gmail.com" && password == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
      return;
    }

    final result =
    await firestoreService.loginUser(email, password);

    if (result == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Credentials")),
      );

      return;
    }

    String role = result['role'];
    String uid = result['uid'];

    // ================= REDIRECT =================

    if (role == 'student') {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(userId: uid),
        ),
      );

    } else if (role == 'teacher') {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherDashboard(userId: uid, teacherName: '',),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.school,
                    size: 70,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Student Teacher Portal",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // REGISTER LINK
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("New User? Register Here"),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
