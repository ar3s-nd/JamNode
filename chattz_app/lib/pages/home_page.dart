import 'dart:async';
import 'dart:math';
import 'package:chattz_app/components/main_drawer.dart';
import 'package:chattz_app/main.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/group_details_page_body.dart';
import 'package:chattz_app/widgets/group_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, Map<String, dynamic>> groups = {};
  Map<String, Map<String, dynamic>> activeGroups = {};
  Map<String, Map<String, dynamic>> myGroups = {};
  Map<String, dynamic> userDetails = {};
  String user = 'J';
  bool isActiveGroupShown = false;
  bool isLoading = true;
  bool isBuiltAsCard = true;
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulating loading time
      FirestoreServices().listenToGroupChanges(setGroups);
      if (groups.isEmpty) await setGroups();
      if (userDetails.isEmpty) await setUser();
    } catch (e) {
      // handle error
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> setGroups() async {
    Map<String, Map<String, dynamic>> newGroups = groups;
    try {
      newGroups = await FirestoreServices().getDetailsOfAllGroups();
    } catch (e) {
      // handle error
    }
    if (mounted) {
      setState(() {
        groups = newGroups;
        activeGroups.clear();
        myGroups.clear();

        groups.forEach(
          (key, value) {
            if (!value['members'].contains(currentUserId)) {
              activeGroups[key] = value;
            } else {
              myGroups[key] = value;
            }
          },
        );
      });
    }
  }

  Future<void> setUser() async {
    Map<String, dynamic> newUser = userDetails;
    try {
      newUser = await UserService().getUserDetailsById(currentUserId);
    } catch (e) {
      // handle error
    }
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
      if (user['groups'].length >= numberOfGroupsPerPersonGlobal) {
        throw 'You can only be a part of max $numberOfGroupsPerPersonGlobal groups at a time';
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
      FadePageRoute(
        page: ChatPage(
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
          ),
        ),
      );
    }

    return LiquidPullToRefresh(
      animSpeedFactor: 2,
      onRefresh: () async {
        try {
          await Future.delayed(const Duration(milliseconds: 1500));
          await setGroups();
          await setUser();
        } catch (e) {
          showErrorMessage(e.toString());
        }
      },
      color: Colors.teal.shade900,
      backgroundColor: Colors.black,
      showChildOpacityTransition: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        drawer: MainDrawer(
          isActiveGroupShown: isActiveGroupShown,
          onActiveGroupChanged: (value) {
            if (mounted) {
              setState(() {
                isActiveGroupShown = value;
              });
            }
          },
          userData: userDetails,
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.tealAccent.withOpacity(0.85),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: RichText(
            text: TextSpan(
              text: isActiveGroupShown ? 'Active ' : 'My ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Jams',
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
            if (isActiveGroupShown && activeGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    if (isBuiltAsCard) {
                      _iconAnimationController.forward();
                      isBuiltAsCard = false;
                    } else {
                      _iconAnimationController.reverse();
                      isBuiltAsCard = true;
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isBuiltAsCard
                          ? Icons.grid_view_rounded
                          : Icons.list_rounded,
                      key: ValueKey<bool>(isBuiltAsCard),
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
              )
          ],
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade900,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: groups.isNotEmpty
                  ? isActiveGroupShown
                      ? _buildActiveGroups()
                      : _buildMyGroups()
                  : _buildEmptyGroupsPage(),
            ),
          ),
        ),
        floatingActionButton: Offstage(
          offstage: activeGroups.isEmpty ||
              (!isActiveGroupShown && myGroups.isEmpty) ||
              isActiveGroupShown,
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

  Widget _buildGroupsList(
      {required Map<String, Map<String, dynamic>> groupsToShow}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: groupsToShow.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: GroupListCard(
                        group: groupsToShow[groupsToShow.keys.toList()[index]]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyGroups() {
    return myGroups.isNotEmpty
        ? _buildGroupsList(groupsToShow: myGroups)
        : _buildEmptyGroupsPage();
  }

  Widget _buildActiveGroups() {
    return activeGroups.isNotEmpty
        ? isBuiltAsCard
            ? CarouselSlider(
                key: ValueKey(groups['groupId']),
                unlimitedMode: true,
                slideTransform: const ForegroundToBackgroundTransform(),
                slideIndicator: CircularWaveSlideIndicator(
                  padding: const EdgeInsets.only(bottom: 20),
                  currentIndicatorColor: Colors.teal.shade900,
                  indicatorBackgroundColor: Colors.teal.shade400,
                  indicatorRadius: 5,
                  indicatorBorderWidth: 1,
                ),
                children: [
                  for (String key in activeGroups.keys)
                    GroupDetailsPageBody(
                      groupDetails: activeGroups[key]!,
                    )
                ],
              )
            : _buildGroupsList(groupsToShow: activeGroups)
        : _buildEmptyGroupsPage();
  }

  Widget _buildEmptyGroupsPage() {
    return AnimationLimiter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
                // child: Icon(
                //   Icons.groups_2_rounded,
                //   size: MediaQuery.of(context).size.width *
                //       0.3, // Dynamic icon size
                //   color: Colors.tealAccent.shade700,
                // ),
                child: Lottie.asset('assets/animations/no_jams_yet.json',
                    backgroundLoading: false,
                    width: MediaQuery.of(context).size.width * 0.65,
                    repeat: false),
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
                    text: 'Here!',
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

            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

            // Primary Action Button (ElevatedButton)
            FractionallySizedBox(
              widthFactor: 0.7, // Ensures button adapts to screen size
              child: ElevatedButton.icon(
                onPressed: () {
                  groups.isEmpty
                      ? createGroup()
                      : activeGroups.isEmpty
                          ? isActiveGroupShown = false
                          : myGroups.isEmpty
                              ? createGroup()
                              : isActiveGroupShown = !isActiveGroupShown;
                  if (mounted) {
                    setState(() {});
                  }
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
                  groups.isEmpty
                      ? 'Create Jam'
                      : activeGroups.isEmpty
                          ? 'View My Jams'
                          : myGroups.isEmpty
                              ? 'Create Jam'
                              : 'Create Jam',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
