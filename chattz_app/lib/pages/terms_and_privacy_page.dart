import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/pages/onboarding.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsAndPrivacyPage extends StatefulWidget {
  const TermsAndPrivacyPage({super.key});

  @override
  State<TermsAndPrivacyPage> createState() => _TermsAndPrivacyPageState();
}

class _TermsAndPrivacyPageState extends State<TermsAndPrivacyPage>
    with SingleTickerProviderStateMixin {
  bool isAgreed = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> terms = [
    'User Data: The chats between users will be stored permanently. Even if everyone leaves the group, the chat data will remain in the database.',
    'Message Storage: Messages will not be encrypted, and no security measures will be applied for data privacy.',
    'Content Moderation: We reserve the right to moderate and remove inappropriate content.',
    'Age Restriction: Users must be 13 years or older to use this service.',
  ];

  final List<String> privacy = [
    'We are committed to protecting your privacy. Your personal information will not be shared with third parties without your consent.',
    'We do not store personal data beyond what is necessary for service functionality.',
    'Your IP address and device information may be logged for security purposes.',
    'We use cookies to enhance your user experience.',
    'Third-party integrations may collect additional data under their own privacy policies.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.tealAccent.shade400, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Terms & Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.tealAccent.shade400,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildSection(
                  'Terms of Service',
                  terms,
                  Icons.gavel_rounded,
                ),
                const SizedBox(height: 20),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.tealAccent.shade400,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Privacy Policy',
                  privacy,
                  Icons.privacy_tip_rounded,
                ),
                const SizedBox(height: 30),
                _buildActionButtons(),
                if (isAgreed) _buildSuccessMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent.shade400, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}.',
                    style: TextStyle(
                      color: Colors.tealAccent.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedButton(
          'Reject',
          Colors.redAccent,
          () {
            HapticFeedback.mediumImpact();
            setState(() => isAgreed = false);
            ErrorDialog.show(
              context: context,
              title: 'Terms Rejected',
              description:
                  'You must accept the terms to continue or else you will be logged out.',
              text1: 'Accept',
              text2: 'Logout',
              onRetry: () {
                UserService().updateProfile(
                  FirebaseAuth.instance.currentUser!.uid,
                  {
                    'gotDetails': true,
                  },
                );
                Navigator.pushReplacement(
                  context,
                  FadePageRoute(page: const HomePage()),
                );
              },
              onClose: () {
                FirebaseAuth.instance.signOut();
                debugPrint('User logged out');
                Navigator.pushReplacement(
                  context,
                  FadePageRoute(page: const OnboardingPage()),
                );
              },
            );
          },
        ),
        const SizedBox(width: 20),
        _buildAnimatedButton(
          'Accept',
          Colors.tealAccent,
          () {
            HapticFeedback.mediumImpact();
            setState(() => isAgreed = true);
            UserService().updateProfile(
              FirebaseAuth.instance.currentUser!.uid,
              {
                'gotDetails': true,
              },
            );
            Navigator.pushReplacement(
              context,
              FadePageRoute(page: const HomePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(
      String text, Color color, VoidCallback onPressed) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isAgreed ? 0.8 : 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade900.withOpacity(0.5),
                    Colors.teal.shade800.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.tealAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.tealAccent.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Thank you for accepting!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
