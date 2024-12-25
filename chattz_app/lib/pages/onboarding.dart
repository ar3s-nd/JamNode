import 'package:chattz_app/pages/flutter_login_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool isLastPage = false;
  late PageController _pageController;
  final Map<int, Map<String, String>> pageData = {
    1: {
      "animation": 'assets/animations/jam_animation.json',
      "title": 'Discover Music Jams',
      "subtitle":
          'Find amazing jams near you, join other musicians, and make beautiful music.',
    },
    2: {
      "animation": 'assets/animations/chatting_animation.json',
      "title": 'Collaborate & Connect',
      "subtitle":
          'Chat with fellow jammers, share ideas, and create music together.',
    },
    3: {
      "animation": 'assets/animations/join_now.json',
      "title": 'Get Started Today!',
      "subtitle":
          'Join a community of musicians and start your jamming journey.',
    },
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal[700]!,
              Colors.teal[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == pageData.length - 1;
                  });
                },
                children: [
                  for (int i = 1; i <= pageData.length; i++)
                    AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - (i - 1);
                          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                        }
                        return Transform.scale(
                          scale: value,
                          child: _buildPage(size, i),
                        );
                      },
                    ),
                ],
              ),
              Container(
                alignment: const Alignment(0, 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(pageData.length - 1,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOut);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.03),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: pageData.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.tealAccent,
                        dotHeight: size.height * 0.012,
                        dotWidth: size.height * 0.012,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_pageController.page! < pageData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                          );
                        } else {
                          Navigator.push(
                            context,
                            FadePageRoute(
                              page: const FlutterLoginPage(),
                            ),
                          );
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          key: ValueKey<bool>(isLastPage),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.03,
                          ),
                          decoration: BoxDecoration(
                            color: isLastPage
                                ? Colors.tealAccent
                                : Colors.transparent,
                            borderRadius:
                                isLastPage ? BorderRadius.circular(15) : null,
                          ),
                          child: Text(
                            isLastPage ? 'Join' : 'Next',
                            style: TextStyle(
                              color:
                                  isLastPage ? Colors.black : Colors.tealAccent,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Size size, int pageNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          pageData[pageNumber]!['animation']!,
          // height: size.height * 0.4,
        ),
        SizedBox(height: size.height * 0.03),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: pageData[pageNumber]!['title']!.split(' ')[0],
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: size.width * 0.08,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: pageData[pageNumber]!['title']!
                    .substring(pageData[pageNumber]!['title']!.indexOf(' ')),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Text(
            pageData[pageNumber]!['subtitle']!,
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.045,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
