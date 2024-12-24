import 'package:chattz_app/components/skill_slider.dart';
import 'package:chattz_app/pages/auth_page.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GetSkillLevelPage extends StatefulWidget {
  final List<String> skills;

  const GetSkillLevelPage({
    super.key,
    required this.skills,
  });

  @override
  State<GetSkillLevelPage> createState() => _GetSkillLevelPage();
}

class _GetSkillLevelPage extends State<GetSkillLevelPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, int> level = {};
  bool isSkillUpdated = false; // Tracks if any skill slider is updated

  @override
  void initState() {
    super.initState();
    for (String skill in widget.skills) {
      level[skill] = 0;
    }
  }

  void updateSkill(String skill, int value) {
    if (mounted) {
      setState(() {
        level[skill] = value;
        // Check if any skill slider has been updated
        isSkillUpdated = level.values.any((value) => value > 0);
      });
    }
  }

  checkPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  pushReplacement() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  void submitDetails() async {
    // loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.teal[900],
          ));
        });

    // try creating the user
    try {
      level.removeWhere((key, value) => value == 0);
      if (level.isEmpty) {
        throw "Please rate at least one skill";
      }
      Map<String, dynamic> userDetails = {
        "gotDetails": true,
        "skills": level,
      };
      await UserService()
          .updateProfile(FirebaseAuth.instance.currentUser!.uid, userDetails);
      checkPop();
      pushReplacement();
    } catch (e) {
      // pop the loading circle
      checkPop();

      // show error message
      showErrorMessage(e.toString());
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return LiquidPullToRefresh(
      animSpeedFactor: 2,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {});
        }
      },
      color: Colors.teal.shade900,
      backgroundColor: Colors.black,
      showChildOpacityTransition: false,
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
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF2D1F3D),
                Colors.teal.shade900,
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.03,
                horizontal: screenWidth * 0.05,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Rate your ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Skills',
                              style: TextStyle(
                                color: Colors.teal[200],
                                fontSize: 26,
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
                        'Adjust the sliders to indicate your skill level.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Generate sliders for each skill
                    Column(
                      children: widget.skills.map((skill) {
                        return _buildSkillSlider(skill, screenWidth);
                      }).toList(),
                    ),
                    // _buildSkillList(screenWidth),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([]),
                        builder: (context, _) {
                          return ElevatedButton(
                            onPressed: isSkillUpdated
                                ? () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      // Handle login logic
                                      submitDetails();
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSkillUpdated
                                  ? const Color.fromARGB(255, 20, 117, 101)
                                  : Colors.grey[900],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Finish',
                              style: TextStyle(
                                color: isSkillUpdated
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSlider(String skill, double screenWidth) {
    return SkillSlider(
      screenWidth: screenWidth,
      skill: skill,
      level: level,
      onChanged: updateSkill,
      showSlider: true,
    );
  }
}
