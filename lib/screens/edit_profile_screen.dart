import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _firstName.text = data['first_name'] ?? '';
      _lastName.text = data['last_name'] ?? '';
      _phone.text = data['phone_number'] ?? '';
      _address.text = data['address'] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'phone_number': _phone.text.trim(),
      'address': _address.text.trim(),
    });

    Fluttertoast.showToast(msg: "Profile updated");
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
