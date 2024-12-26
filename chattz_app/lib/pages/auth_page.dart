import 'package:chattz_app/main.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:chattz_app/pages/terms_and_privacy_page.dart';
import 'package:chattz_app/widgets/group_list_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  Future<bool> _checkUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final gotDetails = userDoc.get('gotDetails');
        return gotDetails == true;
      }
      return false;
    } catch (e) {
      // Handle errors like network issues or missing fields
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                // Check Firestore for gotDetails field
                return FutureBuilder<bool>(
                  future: _checkUserDetails(user.uid),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState == ConnectionState.done) {
                      if (asyncSnapshot.hasError) {
                        return const OnboardingPage();
                      }

                      if (asyncSnapshot.hasData) {
                        final gotDetails = asyncSnapshot.data!;
                        return gotDetails
                            ? const HomePage()
                            : const TermsAndPrivacyPage();
                      } else {
                        return const OnboardingPage();
                      }
                    } else {
                      // Show loading while waiting for Firestore
                      return const LoadingScreen();
                    }
                  },
                );
              }
            } else {
              // If no user is logged in, navigate to the onboarding page
              return const OnboardingPage();
            }
          }

          // Show loading screen while Firebase is checking the auth state
          return const ShimmerOverlay();
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight,
      width: screenWidth,
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
  }
}
