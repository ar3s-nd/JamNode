import 'package:chattz_app/pages/get_details_page.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  bool gotDetails = false;
  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Automatically navigates when user logs in or logs out
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // If user is logged in, go to home page
              return const HomePage();
            } else {
              // If user is not logged in, go to onboarding page or the get details page
              if (gotDetails) {}
              return gotDetails
                  ? const OnboardingPage()
                  : const GetDetailsPage("", "");
            }
          }

          // Show loading screen while Firebase is checking the auth state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
