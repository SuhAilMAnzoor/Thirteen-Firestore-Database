import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thirteen_firestore_database/screens/login_screen.dart';
import 'package:thirteen_firestore_database/screens/edit_profile_screen.dart';

class GetUserName extends StatefulWidget {
  final String? documentId;

  const GetUserName({super.key, this.documentId});

  @override
  State<GetUserName> createState() => _GetUserNameState();
}

class _GetUserNameState extends State<GetUserName> {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? '';
    final String docIdToFetch = widget.documentId ?? uid;

    // Firebase Cloud Storage Collections >>> for Auth and Add User Mangement Users
    //  For Auth Collection
    final usersMain = FirebaseFirestore.instance.collection('Users');
    //  For Add User Mangement Collection
    final usersFromAddUserManagement =
        FirebaseFirestore.instance.collection('users');

    // Who is Virewing
    final bool isOwnerOfPage = currentUser != null && docIdToFetch == uid;
    final bool isEmailPasswordAuth =
        currentUser?.providerData.any((p) => p.providerId == 'password') ??
            false;
    final bool showOwnerOptions = isOwnerOfPage && isEmailPasswordAuth;

    return FutureBuilder<DocumentSnapshot>(
      future: usersMain.doc(docIdToFetch).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text("Something went wrong")));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
          return _buildUserDetailScreen(
              context, data, docIdToFetch, showOwnerOptions);
        }

        // If Users are not from Firebase Auth Email and Password  Return the Users From Add User Mangement
        return FutureBuilder<DocumentSnapshot>(
          future: usersFromAddUserManagement.doc(docIdToFetch).get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasError) {
              return const Scaffold(
                  body: Center(child: Text("Something went wrong")));
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User document not found.")),
              );
            }
            final data = (snap.data!.data() as Map<String, dynamic>?) ?? {};
            return _buildUserDetailScreen(
                context, data, docIdToFetch, showOwnerOptions);
          },
        );
      },
    );
  }

  Widget _buildUserDetailScreen(
    BuildContext context,
    Map<String, dynamic> data,
    String docIdToFetch,
    bool showOwnerOptions,
  ) {
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
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Show only for Firebase Auth User (email/password)  Edit Profile & Logout Buttons
            if (showOwnerOptions)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                  setState(
                      () {}); // When editing the information update the User Profile Screen to show changes
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
        child: ListView(children: [
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
                  const Text("User Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          : 'N/A'),
                  const SizedBox(height: 15),
                  _readonlyField(
                      "Phone Number",
                      ((data['phone_number'] ?? data['contact'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                          ? (data['phone_number'] ?? data['contact']).toString()
                          : 'N/A'),
                  const SizedBox(height: 15),
                  _readonlyField(
                      "Address",
                      (data['address'] ?? '').toString().trim().isNotEmpty
                          ? data['address'].toString()
                          : 'N/A'),
                  const SizedBox(height: 15),
                  _readonlyField("Email", userEmail),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Firebase Auth (email/password): Users Show "Logout" Button and performs LOGOUT Functionality
          // From AddUserManagement: Users "Back to User List"  Button and just pops back to the User List That is main Page
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (showOwnerOptions) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(showOwnerOptions ? "Logout" : "Back to User List"),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextFormField(
      initialValue: value.isNotEmpty ? value : 'N/A',
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
