import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // List<String> bandRoles = [];
  // List<String> sports = []

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "Chattz",
        home: AuthPage(),
        debugShowCheckedModeBanner: false,
        color: Colors.grey);
  }
}
