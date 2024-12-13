import 'dart:async';
import 'dart:math';
import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String generateRandomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return List.generate(length, (index) {
    int randomIndex = random.nextInt(characters.length);
    return characters[randomIndex];
  }).join();
}

Map<String, Map<String, dynamic>> userDetails = {
  FirebaseAuth.instance.currentUser!.uid: {
    "collegeId": 1,
    "collegeName": "collegeName",
    "email": "Email",
    "gotDetails": false,
    "name": "Name",
    "Phone Number": "Phone Number",
    "imageUrl":
        "https://img.freepik.com/free-psd/3d-icon-social-media-app_23-2150049569.jpg?t=st=1734021272~exp=1734024872~hmac=e1631345b981bb44b56fa08ae2ed84a3c155df03ac3e688f117ddf8701e24976&w=826",
  }
};

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, List<Message>> _messages = {};
  Map<String, dynamic> groupDetails = {
    "name": "JamNode",
    "members": [],
    "imageUrl":
        "https://img.freepik.com/free-vector/cartoon-character-design-illustration-professional-band_1362-117.jpg"
  };

  void checkDatabasePeriodically() {
    Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        List<String> uids = userDetails.keys.toList();
        uids.shuffle();
        String uid = uids[0];
        Message message = Message(
            id: DateTime.now().toString(),
            text: generateRandomString(10),
            senderUserId: uid,
            timestamp: DateTime(2023));
        print(message.timestamp);
        await FirestoreServices().addMessage(userId, message);
      } catch (e) {
        // print("Error checking database: $e");
      }
    });
  }

  void listenToChatChanges() async {
    String groupId = await FirestoreServices()
        .getGroupId(FirebaseAuth.instance.currentUser!.uid);
    debugPrint(groupId);
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .collection('chats') // Listen to changes in the "Chats" subcollection
        .snapshots()
        .listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added ||
              docChange.type == DocumentChangeType.modified) {
            setMessages();
          }
        }
      },
      onError: (error) {
        // print("Error listening to database changes: $error");
      },
    );
  }

  void setMessages() async {
    _messages = await FirestoreServices()
        .getChats(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      setState(() {});
    }
  }

  void setGroupDetails() async {
    groupDetails = await FirestoreServices()
        .getGroupDetailsByUserId(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      setState(() {});
    }
  }

  void setUserDetails(id) async {
    userDetails = await UserService().getUserDetailsByGroupId();
    if (mounted) {
      setState(() {});
      debugPrint(userDetails.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // checkDatabasePeriodically();
    // AutoMessageService().sendMessageToDataBasePeriodically();
    setMessages();
    setGroupDetails();
    setUserDetails(FirebaseAuth.instance.currentUser!.uid);
    listenToChatChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 1,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => {
            if (Navigator.canPop(context)) {Navigator.pop(context)}
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(groupDetails["imageUrl"]),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupDetails["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${groupDetails['members'].length} members",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Colors.yellow.shade900,
              // Colors.blue.shade200,
              // Colors.teal.shade900,
              Colors.teal.shade900,
              Colors.transparent,
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.keys.length,
                    itemBuilder: (context, index) {
                      final date = _messages.keys.elementAt(index);
                      final messages = _messages[date]!;

                      // Sort the messages by timestamp
                      messages
                          .sort((a, b) => a.timestamp.compareTo(b.timestamp));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Displaying date like in the image (centered, grey background)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          // Displaying the list of messages for the current date
                          ...messages.map(
                            (message) => MessageBubble(
                                userDetails: userDetails, message: message),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.mic_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Write your message',
                            hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w200),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.send_rounded, color: Colors.white),
                        color: Colors.white,
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            setState(() {
                              FirestoreServices().addMessage(
                                  userId,
                                  Message(
                                    id: DateTime.now().toString(),
                                    text: _messageController.text,
                                    senderUserId: userId,
                                    timestamp: DateTime.now(),
                                  ));
                              _messageController.clear();
                            });
                            _scrollToBottom();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 100,
              right: 8,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_downward_rounded),
                onPressed: () {
                  setState(
                    () {
                      _scrollToBottom();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    // Get the height of the screen and the height of the keyboard
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Scroll to the bottom of the chat, but account for the keyboard height
    double targetPosition = _scrollController.position.maxScrollExtent;
    if (keyboardHeight > 0) {
      targetPosition -=
          keyboardHeight; // Adjust scroll position if the keyboard is visible
    }

    // Animate scroll to the target position
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
