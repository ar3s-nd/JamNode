import 'package:chattz_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get isFormValid =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Sign up with ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Email',
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
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Get chatting with friends and family today by\nsigning up for our chat app!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Your name',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Your email',
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
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _nameController,
                              _emailController,
                              _passwordController,
                              _confirmPasswordController,
                            ]),
                            builder: (context, _) {
                              return ElevatedButton(
                                onPressed: isFormValid
                                    ? () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          // Handle sign up logic
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? Colors.teal[900]
                                      : Colors.grey[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Create an account',
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
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
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
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[200]),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.teal[200]!),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: errorStyle,
      ),
      validator: validator,
    );
  }
}
