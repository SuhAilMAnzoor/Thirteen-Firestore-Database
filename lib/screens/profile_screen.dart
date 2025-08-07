import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(data['first_name'][0]),
                  ),
                  const SizedBox(height: 16),
                  Text("${data['first_name']} ${data['last_name']}",
                      style: const TextStyle(fontSize: 20)),
                  Text(data['email']),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                  ),
                  const SizedBox(height: 20),
                  if (data['role'] == 'admin') // Only for admins
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (_) => const RetrieveUserDataFromUser()),
                        // );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text("My Account Settings"),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
