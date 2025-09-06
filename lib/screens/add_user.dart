import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
// This function adds a user to the Firestore database under the "users" collection
// with a hardcoded name and contact number. It uses the `add` method to create a new document
// and handles success and error cases with print statements. You can replace these with
// more user-friendly notifications like a snackbar or toast..
  addUser() {
    FirebaseFirestore.instance
        .collection("users")
        .add({
          "name": "Sohail",
          "contact": "03457588999",
        })
        .then((value) => print("User Added")) // This is Extra Handling, else
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              addUser();
            },
            child: const Text("Add User"),
          ),
        ],
      ),
    ));
  }
}
