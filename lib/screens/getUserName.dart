import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thirteen_firestore_database/screens/login_screen.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Document does not exist")),
          );
        }

        // Retrieve user data
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text("User Profile"),
            backgroundColor: Colors.blue,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("User Details",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: data['first_name'],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue: data['last_name'],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue: data['age'],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Age",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue: data['phone_number'],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue: data['address'],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Address",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue:
                              data['email'] != null && data['email'].isNotEmpty
                                  ? data['email']
                                  : "No Email Found against user account",
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      // Navigate to login screen and remove the current screen from stack
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text("Log Out"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
