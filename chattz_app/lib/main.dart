import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

List<String> skills = [];
int numberOfGroupsPerPerson = 5;
int timeOutForGroups = 5;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  skills = await FirestoreServices().getSkills();
  Map<String, dynamic> basic =
      await FirestoreServices().getAppDataAndSettings();

  skills = List<String>.from(basic['skills']);
  numberOfGroupsPerPerson = basic['numberOfGroupsPerPerson'] as int;
  timeOutForGroups = basic['timeoutForGroups'] as int;
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
