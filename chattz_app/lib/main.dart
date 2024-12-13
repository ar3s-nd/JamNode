import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

List<String> roles = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  roles = await FirestoreServices().getRoles();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
