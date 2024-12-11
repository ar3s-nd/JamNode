import 'package:chattz_app/pages/login_page.dart';
import 'package:chattz_app/pages/register_page.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2D1F3D),
              Colors.teal.shade900,
              Colors.black,
              // const Color(0xFF1D1128),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    // Image.asset(
                    //   'assets/chatbox_logo.png',
                    //   width: 24,
                    //   height: 24,
                    //   color: Colors.white,
                    // ),
                    SizedBox(width: 8),
                    Text(
                      'Chatbox',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const Text(
                  'Connect\nfriends\neasily &\nquickly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Our chat app is the perfect way to stay\nconnected with friends and family.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: 'assets/images/facebook_logo.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    _SocialButton(
                      icon: 'assets/images/google_logo.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    _SocialButton(
                      icon: 'assets/images/apple_logo.png',
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign up with mail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()));
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Existing account? ',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              color: Colors.white,
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
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(
        icon,
        width: 56,
        height: 56,
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(1),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
