import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thirteen_firestore_database/firebase_options.dart';
import 'package:thirteen_firestore_database/screens/login_screen.dart';
import 'package:thirteen_firestore_database/screens/retrieve_user_data_from_User.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginScreen());
  }
}
