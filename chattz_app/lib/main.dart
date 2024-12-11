import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "Chattz",
        home: OnboardingPage(),
        debugShowCheckedModeBanner: false,
        color: Colors.grey);
  }
}
