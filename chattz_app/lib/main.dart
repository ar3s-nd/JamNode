import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

List<String> skillsGlobal = [];
int numberOfGroupsPerPersonGlobal = 5;
int timeOutForGroupsGlobal = 5;
List<String> groupNamesGlobal = [];
List<String> collegeNamesGlobal = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Map<String, dynamic> basic =
      await FirestoreServices().getAppDataAndSettings();

  groupNamesGlobal = List<String>.from(basic['groupNames'] ?? ['JamBuds']);
  skillsGlobal = List<String>.from(basic['skills'] ?? ['Guitar']);
  collegeNamesGlobal =
      List<String>.from(basic['collegeNames'] ?? ['IIT Bombay']);
  skillsGlobal.sort();
  numberOfGroupsPerPersonGlobal = basic['numberOfGroupsPerPerson'] as int;
  timeOutForGroupsGlobal = basic['timeoutForGroups'] as int;

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
        // home: /
        debugShowCheckedModeBanner: false,
        color: Colors.grey);
  }
}
