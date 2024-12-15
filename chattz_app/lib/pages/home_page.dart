import 'package:chattz_app/pages/chat_page.dart';
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
  bool isShownAsCard = true;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, Map<String, dynamic>> groups = {};

  @override
  void initState() {
    super.initState();
    FirestoreServices().listenToGroupChanges(setGroups);
  }

  setGroups() async {
    Map<String, Map<String, dynamic>> newGroups =
        await FirestoreServices().getDetailsOfAllGroups();
    if (mounted) {
      setState(
        () {
          groups = newGroups;
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

    List<String> groupNames = [
      'JamMasters',
      'JamCrew',
      'JamVibe',
      'HarmonyHub',
      'The Jamsters',
      'RhythmNest',
      'JamForge',
      'JamTide',
      'SyncJam',
      'GrooveCircle',
      'EchoJammers',
      'JamPulse',
      'ChordMates',
      'VibeSync',
      'JamFusion',
    ];
    groupNames.shuffle();

    // Create a new group
    Map<String, dynamic> newGroup = {
      'name': groupNames.first,
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
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows content behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            icon: isShownAsCard
                ? const Icon(Icons.format_list_bulleted_rounded)
                : const Icon(Icons.grid_view_rounded),
            color: Colors.teal.shade400,
            onPressed: () {
              setState(() {
                isShownAsCard = !isShownAsCard;
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
        centerTitle: true,
      ),

      body: Container(
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
          child: isShownAsCard
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Currently Active ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          children: [
                            TextSpan(
                              text: 'Jams',
                              style: TextStyle(
                                color: Colors.teal.shade400,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          return GroupListCard(
                            group: groups[groups.keys.toList()[index]]!,
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Center(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create a new Jam or group
          createGroup();
        },
        backgroundColor: Colors.teal.shade600,
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}
