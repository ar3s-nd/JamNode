import 'package:chattz_app/components/skill_slider.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/details_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chattz_app/components/image_circle.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    userData = widget.userData;

    List<String> skills = userData['skills'].keys.toList();
    bool isMe = userData['uid'] == FirebaseAuth.instance.currentUser!.uid;

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        setState(() {});
      },
      color: Colors.tealAccent,
      backgroundColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Container(
          height: height,
          width: width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade900,
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Avatar
                  ImageCircle(
                    letter: userData['name'][0].toUpperCase(),
                    circleRadius: 35,
                    fontSize: 38,
                    colors: [Colors.tealAccent.shade200, Colors.teal],
                  ),

                  // Name Field
                  const SizedBox(height: 16),
                  DetailsCard(
                    update: (String text) async {
                      userData['name'] = text;
                      await UserService()
                          .updateProfile(userData['uid'], userData);
                      setState(() {});
                    },
                    icon: Icons.person,
                    label: 'Name',
                    value: userData['name'],
                    isUpdatable: true,
                    isMe: isMe,
                  ),

                  // Email Field
                  const SizedBox(height: 8),
                  DetailsCard(
                    update: () {},
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: userData['email'],
                    isUpdatable: false,
                    isMe: isMe,
                  ),

                  // College ID Field
                  const SizedBox(height: 8),
                  DetailsCard(
                    update: (String text) async {
                      userData['collegeId'] = text;
                      await UserService()
                          .updateProfile(userData['uid'], userData);
                      setState(() {});
                    },
                    icon: Icons.school,
                    label: 'College ID',
                    value: userData['collegeId'],
                    isUpdatable: true,
                    isMe: isMe,
                  ),

                  // College Name
                  const SizedBox(height: 8),
                  DetailsCard(
                    update: (String text) async {
                      userData['collegeName'] = text;
                      await UserService()
                          .updateProfile(userData['uid'], userData);
                      setState(() {});
                    },
                    icon: Icons.badge_outlined,
                    label: 'College Name',
                    value: userData['collegeName'],
                    isUpdatable: true,
                    isMe: isMe,
                  ),

                  // Skills Slider (Read-only)
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Skills",
                        style: TextStyle(
                          color: Colors.tealAccent.shade400,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: skills.map((skill) {
                      return _buildSkillSlider(skill, width);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSlider(String skill, double screenWidth) {
    return SkillSlider(
      showSlider: true,
      screenWidth: screenWidth,
      skill: skill,
      level: userData['skills'],
      onChanged: (String name, int value) async {
        // Check if the profile belongs to the current logged-in user
        if (userData['uid'] == FirebaseAuth.instance.currentUser!.uid) {
          // If it matches, update the value
          setState(() {
            userData['skills'][name] = value; // Update the skill level
            if (value == 0) {
              userData['skills'].remove(name);
            }
          });
          // Call the service to update the profile data
          await UserService().updateProfile(userData['uid'], userData);
        } else {
          // Optional: Provide feedback if it's not the current user's profile
          debugPrint('You cannot edit someone else\'s profile.');
        }
      },
    );
  }
}
