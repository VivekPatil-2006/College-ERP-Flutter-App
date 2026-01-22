import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = "student";
  bool isPasswordHidden = true;
  bool isLoading = false;

  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= REGISTER =================

  Future<void> register() async {

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      // ✅ Create user in Firebase Auth
      UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = credential.user!.uid;

      // ✅ Create user model
      AppUser user = AppUser(
        id: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(), password: '',
      );

      // ✅ Save to Firestore by role
      if (selectedRole == "student") {

        await firestoreService.createStudent(user);

      } else {

        await firestoreService.createTeacher(user);

      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration Failed")),
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================

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

                  const Icon(Icons.person_add, size: 70),

                  const SizedBox(height: 10),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

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

                  const SizedBox(height: 12),

                  // ROLE
                  DropdownButtonFormField<String>(
                    value: selectedRole,

                    items: const [
                      DropdownMenuItem(
                        value: "student",
                        child: Text("Student"),
                      ),
                      DropdownMenuItem(
                        value: "teacher",
                        child: Text("Teacher"),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Select Role",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,

                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "REGISTER",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
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
