import 'dart:math';

import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterLoginPage extends StatelessWidget {
  static const routeName = '/auth';
  const FlutterLoginPage({super.key});
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2000);

  Future<void> _uploadData(UserCredential result) async {
    try {
      int number = Random().nextInt(100000);

      Map<String, dynamic> userInfoMap = {
        'uid': result.user!.uid,
        'name': 'User$number',
        'email': result.user!.email,
        "collegeName": "",
        "collegeId": "",
        "gotDetails": false,
        'skills': {},
        'groups': [],
      };

      // try adding the user to the database
      await UserService().addUserDetails(userInfoMap, result.user!.uid);
    } catch (e) {
      // handle the error
      debugPrint(e.toString());
    }
  }

  Future<String?> _loginUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _registerUser(SignupData data) async {
    try {
      UserCredential result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      _uploadData(result);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        theme: LoginTheme(
          pageColorDark: Colors.black,
          pageColorLight: Colors.teal.shade800,
          primaryColor: Colors.teal.shade600,
          accentColor: Colors.teal.shade300,
          errorColor: Colors.redAccent,
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 12,
            shadowColor: Colors.teal.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: Colors.teal.shade500,
            highlightColor: Colors.teal.shade200,
            splashColor: Colors.amber.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
          ),
          textFieldStyle: TextStyle(
            color: Colors.teal.shade900,
            fontWeight: FontWeight.w600,
          ),
          inputTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.teal.shade50,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade800, width: 2),
            ),
          ),
          // logo: AssetImage('assets/logo.png'), // Add your app logo here
          titleStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 6,
                color: Colors.black54,
              ),
            ],
          ),
          beforeHeroFontSize: 18,
          afterHeroFontSize: 18,
        ),
        onLogin: _loginUser,
        onSignup: _registerUser,
        onRecoverPassword: _recoverPassword,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(
            FadePageRoute(
              page: const AuthPage(),
            ),
          );
        },
      ),
    );
  }
}
