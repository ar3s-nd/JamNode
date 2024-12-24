import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // If the user is logged in, navigate to the home page
              return const HomePage();
            } else {
              // If no user is logged in, navigate to the login page
              return const OnboardingPage(); // Or FlutterLoginPage
            }
          }

          // Show loading screen while Firebase is checking the auth state
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.shade900,
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: Lottie.asset(
                'assets/animations/loading_animation.json',
                height: 150,
                width: 150,
              ),
            ),
          );
        },
      ),
    );
  }
}
