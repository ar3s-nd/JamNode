import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // if user is logged in, go to home/favourite/profile page
                return const HomePage();
              } else {
                // if user is not logged in, go to login/register page
                return const OnboardingPage();
              }
            }));
  }
}
