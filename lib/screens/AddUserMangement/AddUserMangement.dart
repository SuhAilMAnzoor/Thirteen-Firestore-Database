import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thirteen_firestore_database/screens/get_user_name.dart';

// import this file into main.dart file by using its class name
// This is different from this project but are similar to the project
// This is Users/Employees Book where you can store Employess/User Details
// This is like RegisterBook
class AddUserMangement extends StatefulWidget {
  const AddUserMangement({super.key});

  @override
  State<AddUserMangement> createState() => _AddUserMangementState();
}

class _AddUserMangementState extends State<AddUserMangement> {
  TextEditingController first_nameController = TextEditingController();
  TextEditingController last_nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isUpdate = false;
  String docID = ''; // Store Document ID for updating

  addUser() async {
    if (first_nameController.text.isEmpty ||
        last_nameController.text.isEmpty ||
        contactController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Fields can't be empty!");
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy('new_user_id', descending: true)
          .limit(1)
          .get();

      int newUserId = 1;
      if (snapshot.docs.isNotEmpty) {
        newUserId = (snapshot.docs.first['new_user_id'] ?? 0) + 1;
      }

      String formattedNumber = newUserId.toString().padLeft(2, '0');
      String year = DateTime.now().year.toString();
      String UserID = "USER$formattedNumber$year";

      await FirebaseFirestore.instance.collection("users").add({
        "new_user_id": newUserId,
        "user_id": UserID,
        "first_name": first_nameController.text,
        "last_name": last_nameController.text,
        "address": addressController.text,
        "contact": contactController.text,
        "email": emailController.text,
      });
      Fluttertoast.showToast(
          msg: "User Added Successfully (ID: $newUserId)",
          backgroundColor: Colors.green);

      first_nameController.clear();
      last_nameController.clear();
      addressController.clear();
      contactController.clear();
      emailController.clear();
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    }
  }

  updateUser() {
    if (first_nameController.text.isEmpty ||
        last_nameController.text.isEmpty ||
        contactController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Fields cannot be empty!", backgroundColor: Colors.red);
      return;
    }

    FirebaseFirestore.instance.collection("users").doc(docID).update({
      'first_name': first_nameController.text,
      "last_name": last_nameController.text,
      "address": addressController.text,
      "contact": contactController.text,
      "email": emailController.text,
    }).then((_) {
      Fluttertoast.showToast(
          msg: "User Updated Successfully!", backgroundColor: Colors.green);
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error: $error", backgroundColor: Colors.red);
    });

    first_nameController.clear();
    contactController.clear();
    emailController.clear();
    last_nameController.clear();
    addressController.clear();
    Navigator.pop(context);
  }

  void deleteUser() async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(docID).delete();
      Fluttertoast.showToast(
          msg: "User Deleted Successfully!", backgroundColor: Colors.red);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    }
  }

  void showEditDialog(String docId, Map<String, dynamic> data) {
    final firstNameController = TextEditingController(text: data['first_name']);
    final lastNameController = TextEditingController(text: data['last_name']);
    final emailController = TextEditingController(text: data['email']);
    final phoneController = TextEditingController(text: data['contact']);
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
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address")),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number")),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(docId)
                  .update({
                'first_name': firstNameController.text,
                'last_name': lastNameController.text,
                'email': emailController.text,
                'address': addressController.text,
                'contact': phoneController.text,
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

  customModalBottomSheetWidget() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 10.0,
                right: 10.0,
                top: 10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: first_nameController,
                  decoration: const InputDecoration(labelText: "First Name")),
              TextField(
                  controller: last_nameController,
                  decoration: const InputDecoration(labelText: "Last Name")),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address")),
              TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: "Contact")),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (isUpdate) {
                      updateUser();
                    } else {
                      addUser();
                    }
                  },
                  child: Text(isUpdate ? "Update" : "Add"))
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isUpdate = false;
              first_nameController.clear();
              contactController.clear();
              emailController.clear();
            });
            customModalBottomSheetWidget();
          },
          child: const Icon((Icons.add)),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot usersData = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        clipBehavior: Clip.antiAlias,
                        elevation: 30,
                        margin:
                            const EdgeInsets.only(top: 5, right: 5, left: 5),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("User ID: ${usersData.get('user_id')}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                Text(
                                    "Name: ${usersData.get('first_name')} ${usersData.get('last_name')}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "Address: ${usersData.get(
                                      'address',
                                    )}",
                                    style: const TextStyle(fontSize: 14)),
                                Text(
                                    "Contact: ${usersData.get(
                                      'contact',
                                    )}",
                                    style: const TextStyle(fontSize: 14)),
                              ]),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                onPressed: () {
                                  docID = usersData.id;
                                  final data = Map<String, dynamic>.from(
                                      usersData.data() as Map);
                                  showEditDialog(docID, data);
                                },
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue)),
                            IconButton(
                                onPressed: () {
                                  docID = usersData.id; // fixed
                                  deleteUser();
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.red)),
                          ]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GetUserName(documentId: usersData.id)));
                          },
                        ),
                      ),
                    );
                  });
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
