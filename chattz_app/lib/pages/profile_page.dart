import 'package:chattz_app/components/skill_slider.dart';
import 'package:chattz_app/main.dart';
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
  bool isMe = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    userData = widget.userData;
    isMe = userData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    List<String> skills = userData['skills'].keys.toList();
    isMe = false;

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
                  userData['skills'].isNotEmpty
                      ? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                "Skills",
                                style: TextStyle(
                                  color: Colors.tealAccent.shade400,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isMe)
                              _buildMultiSelectDropDownField(
                                label: 'Select Your Skills',
                                items: skillsGlobal,
                                onConfirm: (values) async {
                                  userData['skills'] = values;
                                  await UserService()
                                      .updateProfile(userData['uid'], userData);
                                  setState(() {});
                                },
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade600.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.multitrack_audio_rounded,
                                      color: Colors.teal.shade400),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Just Here for fun',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe) const Spacer(),
                            if (isMe)
                              _buildMultiSelectDropDownField(
                                label: 'Select Your Skills',
                                items: skillsGlobal,
                                onConfirm: (values) async {
                                  userData['skills'] = values;
                                  await UserService()
                                      .updateProfile(userData['uid'], userData);
                                  setState(() {});
                                },
                              ),
                            const Spacer(),
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

  Widget _buildMultiSelectDropDownField({
    required String label,
    required List<String> items,
    required void Function(Map<String, int>) onConfirm,
  }) {
    debugPrint(userData['skills'].keys.toString());
    // userData['skills'].keys.toList();
    userData['skills'].removeWhere((key, value) => value == 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Constrained Dropdown width and height
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.teal[200]!),
              ),
            ),
            isExpanded: true,
            iconSize: 30, // Adjust icon size
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors
                        .grey[850], // Subtle background for the entire tile
                    borderRadius: BorderRadius.circular(
                        8), // Rounded corners for the tile
                  ),
                  child: Row(
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Slightly larger font size
                          fontWeight: FontWeight.w500, // Semi-bold for emphasis
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              // Show "Select Interests" always as the selected item
              return items.map((_) {
                return Text(
                  'Add Skills',
                  // 'Select Interests',
                  style: TextStyle(
                    color: Colors.teal[200],
                    fontWeight: FontWeight.w400,
                  ),
                );
              }).toList();
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  // Add the selected skill to the user's profile
                  if (!userData['skills'].containsKey(value)) {
                    userData['skills'][value] = 1;
                    Map<String, int> sortedMap = Map.fromEntries(
                      userData['skills'].entries.toList()
                        ..sort((MapEntry<String, int> a,
                                MapEntry<String, int> b) =>
                            a.key.compareTo(b.key)),
                    );
                    userData['skills'] = sortedMap;
                  }

                  // Call the onConfirm callback with the updated selected skills
                  onConfirm(userData['skills']);
                });
              }
            },
            hint: Text(
              'Update Skills',
              style: TextStyle(
                color: Colors.teal[200],
                fontWeight: FontWeight.w400,
              ),
            ),
            dropdownColor: Colors.grey[900], // Dropdown background color
            itemHeight: 48, // Limit the height of each dropdown item
          ),
        ),
        const SizedBox(height: 8),
        if (userData['skills'].isEmpty)
          Text(
            'Please select at least one',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }

  void checkPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildSkillSlider(String skill, double screenWidth) {
    return SkillSlider(
      showSlider: isMe,
      screenWidth: screenWidth,
      skill: skill,
      level: userData['skills'],
      onChanged: (String name, int value) async {
        // Check if the profile belongs to the current logged-in user
        bool pop = false;
        if (isMe) {
          // If it matches, update the value
          setState(() {
            userData['skills'][name] = value; // Update the skill level
            if (value == 0) {
              showDialog(
                context: context,
                builder: (context) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.teal[900],
                  ));
                },
              );
              userData['skills'].remove(name);
              pop = true;
            }
          });
          // Call the service to update the profile data
          await UserService().updateProfile(userData['uid'], userData);
        } else {
          // Optional: Provide feedback if it's not the current user's profile
          debugPrint('You cannot edit someone else\'s profile.');
        }
        if (pop) {
          checkPop();
        }
      },
    );
  }
}
