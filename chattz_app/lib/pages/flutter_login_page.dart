import 'dart:math';

import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';

class FlutterLoginPage extends StatelessWidget {
  static const routeName = '/auth';

  const FlutterLoginPage({super.key});

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2000);

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

      int number = Random().nextInt(100000);

      Map<String, dynamic> userInfoMap = {
        'uid': result.user!.uid,
        'name': 'User$number',
        'email': data.name,
        "collegeName": "",
        "collegeId": "",
        "gotDetails": false,
        'skills': {},
        'groups': [],
      };

      // try adding the user to the database
      await UserService().addUserDetails(userInfoMap, result.user!.uid);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        theme: LoginTheme(
          pageColorDark: Colors.black,
          pageColorLight: Colors.teal.shade900,
          // primaryColor: Colors.teal.shade700,
          errorColor: Colors.redAccent,
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          buttonTheme: LoginButtonTheme(
            backgroundColor: Colors.deepPurple.shade600,
            highlightColor: Colors.deepPurple.shade300,
            splashColor: Colors.deepPurple.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          textFieldStyle: TextStyle(color: Colors.deepPurple.shade800),
          inputTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple.shade700),
            ),
          ),
        ),
        onLogin: _loginUser,
        onSignup: _registerUser,
        onRecoverPassword: (name) async {
          await Future.delayed(loginTime);
          return null;
        },
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AuthPage(),
            ),
          );
        },
      ),
    );
  }
}
