import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thirteen_firestore_database/screens/get_user_name.dart';
import 'package:thirteen_firestore_database/screens/profile_screen.dart';
import 'package:thirteen_firestore_database/screens/login_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('Users');
  String searchQuery = '';
  String filterStatus = 'All';
  bool isDarkMode = false;
  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  String userName = '';
  String userEmail = '';
  String? profileImageUrl;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        userName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}';
        userEmail = data['email'] ?? '';
        profileImageUrl =
            data['profile_image']; // if you store profile_image url
        isAdmin = data['role'] == 'admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          actions: [
            if (showSearchBar)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.3,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            IconButton(
              icon: Icon(showSearchBar ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  showSearchBar = !showSearchBar;
                  if (!showSearchBar) {
                    searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: filterStatus,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                  DropdownMenuItem(
                      value: 'Unblocked', child: Text('Unblocked')),
                ],
                onChanged: (value) {
                  setState(() {
                    filterStatus = value!;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurple),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 45)
                      : null,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(' My Profile'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.edit),
              //   title: const Text('Edit Profile'),
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (_) => const EditProfileScreen()));
              //   },
              // ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Settings'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AdminPanel()));
                  },
                ),
              const Divider(),
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
        body: buildUserList(),
      ),
    );
  }

  Widget buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final matchesSearch = data['first_name']
                      ?.toLowerCase()
                      .contains(searchQuery) ==
                  true ||
              data['last_name']?.toLowerCase().contains(searchQuery) == true ||
              data['email']?.toLowerCase().contains(searchQuery) == true ||
              data['phone_number']?.toLowerCase().contains(searchQuery) == true;

          final isBlocked = data['isBlocked'] == true;
          if (filterStatus == 'Blocked' && !isBlocked) return false;
          if (filterStatus == 'Unblocked' && isBlocked) return false;
          return matchesSearch;
        }).toList();

        docs.sort((a, b) {
          final nameA = (a['first_name'] ?? '').toString();
          final nameB = (b['first_name'] ?? '').toString();
          return nameA.compareTo(nameB);
        });

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.shade100,
                    Colors.deepPurpleAccent.shade100
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            data['first_name'][0] ?? '?',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${data['first_name']} ${data['last_name']}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(data['email'] ?? 'No email'),
                              Text(data['phone_number'] ?? ''),
                              if (data['address'] != null)
                                Text(data['address']),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(data['isBlocked'] == true
                              ? Icons.lock
                              : Icons.lock_open),
                          tooltip: data['isBlocked'] == true
                              ? 'Unblock User'
                              : 'Block User',
                          onPressed: () async {
                            await users.doc(docId).update(
                                {'isBlocked': !(data['isBlocked'] == true)});
                            Fluttertoast.showToast(
                              msg: data['isBlocked'] == true
                                  ? "User Unblocked"
                                  : "User Blocked",
                              backgroundColor: Colors.black87,
                              textColor: Colors.white,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit User',
                          onPressed: () => showEditDialog(docId, data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete User',
                          onPressed: () async {
                            await users.doc(docId).delete();
                            Fluttertoast.showToast(
                              msg: "User Deleted",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'View Details',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GetUserName(documentId: docId)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showEditDialog(String docId, Map<String, dynamic> data) {
    final firstNameController = TextEditingController(text: data['first_name']);
    final lastNameController = TextEditingController(text: data['last_name']);
    final emailController = TextEditingController(text: data['email']);
    final phoneController = TextEditingController(text: data['phone_number']);
    final addressController = TextEditingController(text: data['address']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name")),
              TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name")),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email")),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await users.doc(docId).update({
                'first_name': firstNameController.text,
                'last_name': lastNameController.text,
                'email': emailController.text,
                'phone_number': phoneController.text,
                'address': addressController.text,
              });
              Fluttertoast.showToast(
                  msg: "User Updated",
                  backgroundColor: Colors.green,
                  textColor: Colors.white);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
