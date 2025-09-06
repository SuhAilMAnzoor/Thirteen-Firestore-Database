import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thirteen_firestore_database/screens/admin_panel.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController first_nameController = TextEditingController();
  TextEditingController last_nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phone_numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  registerAccount() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      FirebaseFirestore.instance
          .collection("Users")
          .doc(credential.user!.uid)
          .set({
            'first_name': first_nameController.text,
            'last_name': last_nameController.text,
            'address': addressController.text,
            'age': ageController.text,
            'phone_number': phone_numberController.text,
            'email': emailController.text,
            'id': credential.user!.uid,
            'registered_at': DateTime.now().toIso8601String(),
            // 'profile_picture': "https://example.com/default_profile_pic.png",
          })
          .then((value) => print(
              "User Added")) // We can add here toast or snackbar to show the massage to user For Error handling
          .catchError((error) => print("Failed to add user: $error"));

      // Display a SnackBar Message at bottom for 2 seconds and its backgroud color will Green
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!, login with it"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // If account is successful created navigate to Login Screen
      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanel()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The password provided is too week."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The Account already exists for that email."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

// Build Mandatory label widget
  Widget buildManatoryLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Build Border Style
  OutlineInputBorder buildBorder(Color color) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 2.0));
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0, left: 12, right: 12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: first_nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      label: buildManatoryLabel("First Name"),
                      hintText: "Type your first name",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      // Nomral Border
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      // Focused Border when interactive with textfield
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                      // Error Border (when field is not focused)
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0)),

                      // Error Border (When User Iteractive and didn't submit due to empty)
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "First name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: last_nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      label: buildManatoryLabel("Last Name"),
                      hintText: "Type your last name",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: // Error Border (When User Iteractive and didn't submit due to empty)
                          OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Last Name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Address",
                      hintText: "Type your Address",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(15),
                      // ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: "age",
                      hintText: "Type your age",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(15),
                      // ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: phone_numberController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter your Phone Number",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      label: buildManatoryLabel("Email Address"),
                      hintText: "Type your Email Address",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(15),
                      // ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: // Error Border (When User Iteractive and didn't submit due to empty)
                          OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Last Name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextFormField(
                    controller: passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      label: buildManatoryLabel("Password"),
                      hintText: "Enter your Password",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 155, 127, 3),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 4, 54, 119),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: // Error Border (When User Iteractive and didn't submit due to empty)
                          OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "password is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //Register Function
                      registerAccount();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 155, 127, 3),
                    ),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    overlayColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 43, 14, 171).withOpacity(0.1),
                    ),
                    elevation: WidgetStateProperty.all<double>(8.0),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    textStyle: WidgetStateProperty.all<TextStyle>(
                      const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  child: const Text("Register Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
