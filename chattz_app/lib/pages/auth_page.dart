import 'package:chattz_app/pages/get_details_page.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  bool gotDetails = false;

  Future<Map<String, dynamic>?> checkForDetails(String id) async {
    return await UserService().getUserDetailsById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Automatically navigates when user logs in or logs out
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // If user is logged in, check for details
              return FutureBuilder<Map<String, dynamic>?>(
                future: checkForDetails(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, userDetailsSnapshot) {
                  if (userDetailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userDetailsSnapshot.hasData &&
                      userDetailsSnapshot.data?["gotDetails"]) {
                    // If user details are found, go to home page
                    return const HomePage();
                  } else {
                    // If user details are not found, go to get details page
                    return GetDetailsPage(
                      userDetailsSnapshot.data?['name'] ?? '',
                      userDetailsSnapshot.data?['email'] ?? '',
                    );
                  }
                },
              );
            } else {
              // If user is not logged in, go to onboarding page
              return const OnboardingPage();
            }
          }

          // Show loading screen while Firebase is checking the auth state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
