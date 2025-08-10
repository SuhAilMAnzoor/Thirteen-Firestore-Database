import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thirteen_firestore_database/screens/getUserName.dart';
import 'package:thirteen_firestore_database/screens/registerscreen.dart';
import 'package:thirteen_firestore_database/screens/retrieve_users_data_for_admin.dart';

import '../utill/ElevatedButtonColors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextField Controllers for Email and Password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLogin = false;

  // Login Function
  void loginFunction() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill out all fields."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLogin = true; // Show loading indicator
      });

      // Sign in
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Get UID of logged-in user
      String uid = credential.user!.uid;

      // ✅ Check if user is admin from Firestore
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      final data = doc.data();

      if (data != null && data['isAdmin'] == true) {
        // ✅ Navigate to Admin Panel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RetrieveUsersDataForAdmin(),
          ),
        );
      } else {
        // ✅ Navigate to normal user screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GetUserName(documentId: uid),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLogin = false;
      });

      String message;
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else {
          message = "An error occurred. Please try again.";
        }
      } else {
        message = "An unexpected error occurred.";
      }

      // Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Type your email",
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Type your password",
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loginFunction,
              style: ButtonStyles.primaryButtonStyle, // Custom Button Style
              child: const Text("Login"),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegistrationScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: isLogin,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
