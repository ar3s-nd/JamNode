import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void signInUser() async {
    // loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.teal[900],
          ));
        });

    // try to sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // pop the loading circle
      // ignore: use_build_context_synchronously
      checkPop();
      pushReplacement();
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      // ignore: use_build_context_synchronously
      checkPop();

      // show error message
      showErrorMessage(e.code);
    }
  }

  void pushReplacement() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  void checkPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void showErrorMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.teal[900],
              title: Center(
                  child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )));
        });
  }

  bool get isFormValid =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      color: Colors.tealAccent,
      backgroundColor: Colors.black,
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              checkPop();
            },
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.teal.shade900, Colors.black],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Log in to Chattz
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Log in to ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: 'Chattz',
                                style: TextStyle(
                                  color: Colors.teal[200],
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Welcome Back
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Welcome back! Please enter your details.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Email textbox
                      const SizedBox(height: 48),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                        errorStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),

                      // Password Textbox
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),

                      // Forgot password
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password logic
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Colors.teal[200],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Login Button
                      const SizedBox(height: 48),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _emailController,
                            _passwordController,
                          ]),
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: isFormValid
                                  ? () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        // Handle login logic
                                        signInUser();
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFormValid
                                    ? const Color.fromARGB(255, 20, 117, 101)
                                    : Colors.grey[800],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: isFormValid
                                      ? Colors.white
                                      : Colors.grey[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // _buildTextField(controller: controller, label: label)

                      // Link to register page
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to sign up page
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage()));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    color: Colors.teal[200],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextStyle? errorStyle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.teal[300],
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16, // Slightly larger font for readability
        fontWeight: FontWeight.w500, // Semi-bold for better focus
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.teal[200],
          fontSize: 14, // Consistent sizing for label text
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey[700]!), // Darker grey for enabled state
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal[300]!, // Slightly brighter teal for focus
            width: 2, // Slightly thicker underline for focus
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2, // Consistent thickness for error state
          ),
        ),
        errorStyle: errorStyle ??
            const TextStyle(
              color: Colors.redAccent, // Subtle error color
              fontSize: 12, // Slightly smaller for less distraction
              fontWeight: FontWeight.w400,
            ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12), // Adjust padding for better spacing
        hintText: 'Enter $label', // Provide a helpful hint
        hintStyle: TextStyle(
          color: Colors.grey[600], // Subtle hint text
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
      validator: validator,
    );
  }
}
