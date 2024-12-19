import 'dart:math';

import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/main.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/profile_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/group_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isShownAsTiles = true;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, Map<String, dynamic>> groups = {};
  Map<String, dynamic> userDetails = {};
  String user = 'J';
  bool isActiveGroupShown = true;
  Map<String, Map<String, dynamic>> activeGroups = {};
  Map<String, Map<String, dynamic>> myGroups = {};

  @override
  void initState() {
    super.initState();
    FirestoreServices().listenToGroupChanges(setGroups);
    setGroups();
    setUser();
  }

  void setGroups() async {
    Map<String, Map<String, dynamic>> newGroups =
        await FirestoreServices().getDetailsOfAllGroups();
    if (mounted) {
      setState(
        () {
          groups = newGroups;
          activeGroups.clear();
          myGroups.clear();

          groups.forEach((key, value) {
            if (!value['members'].contains(currentUserId)) {
              activeGroups[key] = value;
            } else {
              myGroups[key] = value;
            }
          });
        },
      );
    }
  }

  void setUser() async {
    Map<String, dynamic> newUser =
        await UserService().getUserDetailsById(currentUserId);
    if (mounted) {
      setState(
        () {
          userDetails = newUser;
          user = newUser['name'];
        },
      );
    }
  }

  void createGroup() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: CircularProgressIndicator(
          color: Colors.teal[900],
        ));
      },
    );

    String groupName =
        groupNamesGlobal[Random().nextInt(groupNamesGlobal.length)];

    // Create a new group
    Map<String, dynamic> newGroup = {
      'name': groupName,
      'members': [currentUserId],
      'admins': [currentUserId],
    };

    try {
      Map<String, dynamic> user =
          await UserService().getUserDetailsById(currentUserId);
      if (user['groups'].length >= 3) {
        throw 'You can only be a part of max 3 groups at a time';
      }
      newGroup = await FirestoreServices().createGroup(user, newGroup);

      checkPop();
      pushNavigator(newGroup);
    } catch (e) {
      // show error message
      showErrorMessage(e.toString());
    }
  }

  void checkPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void pushNavigator(Map<String, dynamic> newGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          groupDetails: newGroup,
        ),
      ),
    );
  }

  void showErrorMessage(String errorMessage) {
    checkPop();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.teal[900],
          title: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      setGroups();
    }
    if (user == 'J') {
      setUser();
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        setGroups();
        setUser();
      },
      color: Colors.tealAccent,
      backgroundColor: Colors.black,
      child: Scaffold(
        extendBodyBehindAppBar: true, // Allows content behind the AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            child: Transform.scale(
              scale: MediaQuery.of(context).size.width * 0.00175,
              child: ImageCircle(
                letter: user[0],
                circleRadius: MediaQuery.of(context).size.width * 0.05,
                fontSize: MediaQuery.of(context).size.width * 0.07,
                colors: [Colors.tealAccent.shade200, Colors.teal],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userData: userDetails,
                  ),
                ),
              );
            },
          ),
          title: RichText(
            text: TextSpan(
              text: 'Jam',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Node',
                  style: TextStyle(
                    color: Colors.teal.shade400,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: isShownAsTiles
                  ? const Icon(Icons.format_list_bulleted_rounded)
                  : const Icon(Icons.grid_view_rounded),
              color: Colors.teal.shade400,
              onPressed: () {
                setState(() {
                  isShownAsTiles = !isShownAsTiles;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.teal.shade400,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),

        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: groups.isNotEmpty
                  ? isShownAsTiles
                      ? _buildGroupsPageAsTile()
                      : _buildGroupsPageAsCard()
                  : _buildEmptyGroupsPage(),
            ),
          ),
        ),

        floatingActionButton: Offstage(
          offstage: groups.isEmpty ||
              (!isActiveGroupShown && myGroups.isEmpty) ||
              (isActiveGroupShown && activeGroups.isEmpty),
          child: FloatingActionButton(
            onPressed: () {
              createGroup();
            },
            backgroundColor: Colors.teal.shade600,
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons({
    required String text1,
    required String text2,
    required bool isButtonForActive,
  }) {
    bool isActive = isActiveGroupShown == isButtonForActive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isActiveGroupShown = isButtonForActive;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: !isActive ? Colors.grey.shade800 : null,
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.teal.shade900,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: RichText(
            text: TextSpan(
              text: text1,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade400,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: text2,
                  style: TextStyle(
                    color: isActive
                        ? Colors.tealAccent[700]
                        : Colors.grey.shade500,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsList(
      {required Map<String, Map<String, dynamic>> groupsToShow}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: groupsToShow.length,
            itemBuilder: (context, index) {
              return GroupListCard(
                group: groupsToShow[groupsToShow.keys.toList()[index]]!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGroups() {
    return activeGroups.isNotEmpty
        ? _buildGroupsList(groupsToShow: activeGroups)
        : _buildEmptyGroupsPage();
  }

  Widget _buildMyGroups() {
    return myGroups.isNotEmpty
        ? _buildGroupsList(groupsToShow: myGroups)
        : _buildEmptyGroupsPage();
  }

  Widget _buildGroupsPageAsTile() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToggleButtons(
                text1: 'Active ',
                text2: 'Jams',
                isButtonForActive: true, // Button for Active Jams
              ),
              _buildToggleButtons(
                text1: 'My ',
                text2: 'Jams',
                isButtonForActive: false, // Button for My Jams
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        // Return the respective page
        Expanded(
          child: isActiveGroupShown ? _buildActiveGroups() : _buildMyGroups(),
        ),
      ],
    );
  }

  Widget _buildGroupsPageAsCard() {
    return const Center();
  }

  Widget _buildEmptyGroupsPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Responsive Icon with Box Shadow
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.2),
                  spreadRadius: 0.001,
                  blurRadius: 100,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.groups_2_rounded,
              size:
                  MediaQuery.of(context).size.width * 0.3, // Dynamic icon size
              color: Colors.tealAccent.shade700,
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

        // Responsive Title
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'No ',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width *
                  0.07, // Scalable font size
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Jams ',
                style: TextStyle(
                  color: Colors.tealAccent.shade400,
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              TextSpan(
                text: 'Yet!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.07,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Tap',
            style: TextStyle(
              color: Colors.tealAccent.shade400,
              fontSize:
                  MediaQuery.of(context).size.width * 0.045, // Scalable font
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' below to ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'start creating ',
                style: TextStyle(
                  color: Colors.tealAccent.shade400,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'your own jam.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.04),

        // Primary Action Button (ElevatedButton)
        FractionallySizedBox(
          widthFactor: 0.7, // Ensures button adapts to screen size
          child: ElevatedButton.icon(
            onPressed: () {
              // Action here
              createGroup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.shade700,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.tealAccent.shade100, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: ImageIcon(
              const AssetImage('assets/images/add_group.png'),
              size: MediaQuery.of(context).size.width * 0.065,
            ),
            label: Text(
              'Create Jam',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
