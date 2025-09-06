import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thirteen_firestore_database/screens/login_screen.dart';
import 'package:thirteen_firestore_database/screens/edit_profile_screen.dart';

class GetUserName extends StatelessWidget {
  final String? documentId;

  const GetUserName({super.key, this.documentId});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? '';
    final String docIdToFetch = documentId ?? uid;

    // Collections
    final usersMain = FirebaseFirestore.instance.collection('Users');
    final usersAlt = FirebaseFirestore.instance.collection('users');

    // Determine if the viewer is the owner (same uid) AND via email/password auth
    final providers = currentUser?.providerData ?? const [];
    // Be robust: if providerData is empty but email exists, treat as email/password
    final bool isEmailPasswordAuth = providers.isEmpty
        ? (currentUser?.email != null)
        : providers.any((p) => p.providerId == 'password');

    final bool isOwnerOfPage = currentUser != null && docIdToFetch == uid;
    final bool showOwnerOptions = isOwnerOfPage && isEmailPasswordAuth;

    return FutureBuilder<DocumentSnapshot>(
      future: usersMain.doc(docIdToFetch).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = (snapshot.data!.data() as Map<String, dynamic>?) ??
              <String, dynamic>{};
          return _buildUserDetailScreen(
            context: context,
            data: data,
            showOwnerOptions: showOwnerOptions,
            ownerUid: uid,
          );
        }

        // Fallback to 'users' collection (AddUserMangement)
        return FutureBuilder<DocumentSnapshot>(
          future: usersAlt.doc(docIdToFetch).get(),
          builder: (context, alt) {
            if (alt.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (alt.hasError) {
              return const Scaffold(
                body: Center(child: Text("Something went wrong")),
              );
            }
            if (!alt.hasData || !alt.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User document not found.")),
              );
            }
            final data = (alt.data!.data() as Map<String, dynamic>?) ??
                <String, dynamic>{};
            return _buildUserDetailScreen(
              context: context,
              data: data,
              showOwnerOptions: showOwnerOptions,
              ownerUid: uid,
            );
          },
        );
      },
    );
  }

  Widget _buildUserDetailScreen({
    required BuildContext context,
    required Map<String, dynamic> data,
    required bool showOwnerOptions,
    required String ownerUid,
  }) {
    final String first =
        (data['first_name'] ?? data['name'] ?? '').toString().trim();
    final String last = (data['last_name'] ?? '').toString().trim();
    final String userName =
        (('$first $last').trim().isEmpty) ? 'N/A' : ('$first $last').trim();
    final String userEmail = (data['email'] ?? 'No Email').toString();
    final String? profileImageUrl =
        (data['profileImage'] as String?)?.trim().isNotEmpty == true
            ? data['profileImage'] as String
            : null;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                ),
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            // My Profile — always visible
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // close drawer; you're already here
              },
            ),
            // Only for owner via email/password
            if (showOwnerOptions)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
            if (showOwnerOptions) const Divider(),
            if (showOwnerOptions)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _readonlyField(
                        "First Name", first.isNotEmpty ? first : 'N/A'),
                    const SizedBox(height: 15),
                    _readonlyField("Last Name", last.isNotEmpty ? last : 'N/A'),
                    const SizedBox(height: 15),
                    _readonlyField(
                      "Age",
                      (data['age']?.toString() ?? '').isNotEmpty
                          ? data['age'].toString()
                          : 'N/A',
                    ),
                    const SizedBox(height: 15),
                    _readonlyField(
                      "Phone Number",
                      ((data['phone_number'] ?? data['contact'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                          ? (data['phone_number'] ?? data['contact']).toString()
                          : 'N/A',
                    ),
                    const SizedBox(height: 15),
                    _readonlyField(
                      "Address",
                      (data['address'] ?? '').toString().trim().isNotEmpty
                          ? data['address'].toString()
                          : 'N/A',
                    ),
                    const SizedBox(height: 15),
                    _readonlyField("Email", userEmail),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Bottom button — label & action differ by context
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (showOwnerOptions) {
                    // OWNER (email/password): LOGOUT
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else {
                    // From AddUserMangement: just go back
                    Navigator.pop(context);
                  }
                },
                child: Text(showOwnerOptions ? "Logout" : "Back to User List"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextFormField(
      initialValue: value.isNotEmpty ? value : 'N/A',
      readOnly: true,
      decoration: const InputDecoration(
        labelText: '',
        border: OutlineInputBorder(),
      ).copyWith(labelText: label),
    );
  }
}
