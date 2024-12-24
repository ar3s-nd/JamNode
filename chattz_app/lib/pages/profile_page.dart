import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chattz_app/components/skill_slider.dart';
import 'package:chattz_app/main.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/details_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chattz_app/components/image_circle.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  late Map<String, dynamic> userData;
  late bool isMe;
  late List<String> skills;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    isMe = userData['uid'] == FirebaseAuth.instance.currentUser!.uid;
    skills = userData['skills'].keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      animSpeedFactor: 2,
      onRefresh: _refreshUserData,
      color: Colors.teal.shade900,
      backgroundColor: Colors.white,
      showChildOpacityTransition: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    _buildSkillsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        ImageCircle(
          letter: userData['name'][0].toUpperCase(),
          circleRadius: 50,
          fontSize: 48,
          colors: [Colors.tealAccent.shade200, Colors.teal],
        ),
        const SizedBox(height: 16),
        Text(
          userData['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userData['email'],
          style: TextStyle(
            color: Colors.tealAccent.shade200,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Details'),
        const SizedBox(height: 16),
        DetailsCard(
          update: (value) => updateUserData('name', value),
          icon: Icons.person,
          label: 'Name',
          value: userData['name'],
          isUpdatable: true,
          isMe: isMe,
        ),
        const SizedBox(height: 12),
        DetailsCard(
          update: (value) => updateUserData('collegeId', value),
          icon: Icons.badge_outlined,
          label: 'College ID',
          value: userData['collegeId'],
          isUpdatable: true,
          isMe: isMe,
        ),
        const SizedBox(height: 12),
        DetailsCard(
          update: (value) => updateUserData('collegeName', value),
          icon: Icons.school_rounded,
          label: 'College Name',
          value: userData['collegeName'],
          isUpdatable: true,
          isMe: isMe,
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills'),
        const SizedBox(height: 16),
        if (userData['skills'].isNotEmpty) ...[
          ...skills.asMap().entries.map((entry) {
            int idx = entry.key;
            String skill = entry.value;
            return AnimationConfiguration.staggeredList(
              position: idx,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: SkillSlider(
                    screenWidth: MediaQuery.of(context).size.width,
                    skill: skill,
                    level: Map<String, int>.from(userData['skills']),
                    onChanged: (String skill, int value) {
                      if (mounted) {
                        setState(() {
                          userData['skills'][skill] = value;
                          if (value == 0) {
                            userData['skills'].remove(skill);
                          }
                        });
                      }
                      updateUserData('skills', userData['skills']);
                    },
                    showSlider: isMe,
                  ),
                ),
              ),
            );
          }),
        ] else
          _buildNoSkillsWidget(),
        if (isMe) ...[
          const SizedBox(height: 16),
          _buildAddSkillButton(),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.tealAccent.shade400,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNoSkillsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded, color: Colors.teal.shade400),
          const SizedBox(width: 8),
          const Text(
            'Just here for fun!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillButton() {
    return ElevatedButton.icon(
      onPressed: _showAddSkillDialog,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text('Add Skill', style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Future<void> _refreshUserData() async {
    Map<String, dynamic> newData = userData;
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      newData = await UserService().getUserDetailsById(userData['uid']);
    } catch (e) {
      // Handle error
    }
    if (mounted) {
      setState(() {
        userData = newData;
        skills = userData['skills'].keys.toList();
      });
    }
  }

  Future<void> updateUserData(String field, dynamic value) async {
    if (mounted) {
      setState(() {
        userData[field] = value;
      });
    }
    try {
      await UserService().updateProfile(userData['uid'], userData);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateProfile() async {
    try {
      await UserService().updateProfile(userData['uid'], userData);
    } catch (e) {
      // Handle error
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showAddSkillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add Skill', style: TextStyle(color: Colors.white)),
        content: _buildMultiSelectDropDownField(
          label: 'Select Skill',
          items: skillsGlobal,
          onConfirm: (values) {
            if (mounted) {
              setState(() {
                userData['skills'] = values;
                skills = values.keys.toList();
              });
            }
            _updateProfile();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropDownField({
    required String label,
    required List<String> items,
    required void Function(Map<String, int>) onConfirm,
  }) {
    userData['skills'].removeWhere((key, value) => value == 0);

    return DropdownButtonFormField<String>(
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[850], // Subtle background for the entire tile
              borderRadius:
                  BorderRadius.circular(8), // Rounded corners for the tile
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
          if (mounted) {
            setState(() {
              // Add the selected skill to the user's profile
              if (!userData['skills'].containsKey(value)) {
                userData['skills'][value] = 1;
                Map<String, int> sortedMap = Map.fromEntries(
                  userData['skills'].entries.toList()
                    ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
                        a.key.compareTo(b.key)),
                );
                userData['skills'] = sortedMap;
              }

              // Call the onConfirm callback with the updated selected skills
              onConfirm(userData['skills']);
            });
          }
        }
      },
      hint: Text(
        'Add Skills',
        style: TextStyle(
          color: Colors.teal[200],
          fontWeight: FontWeight.w400,
        ),
      ),
      dropdownColor: Colors.grey[900], // Dropdown background color
      itemHeight: 48, // Limit the height of each dropdown item
    );
  }
}
