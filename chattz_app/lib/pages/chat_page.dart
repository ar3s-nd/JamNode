import 'dart:async';
import 'dart:math';

import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
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
    "College Id": 1,
    "College Name": "College Name",
    "Email": "Email",
    "Got Details": false,
    "Name": "Name",
    "Phone Number": "Phone Number",
    "Image URL":
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
    "Group Name": "JamNode",
    "Members": [],
    "Image URL": "PZHO9s25AlVKpQEdvvu52Rmc0Xf2"
  };

  void checkDatabasePeriodically() {
    Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        bool randomBool = Random().nextBool();
        Message message = Message(
            id: DateTime.now().toString(),
            text: generateRandomString(10),
            senderUserId: Random().nextBool() ? "user2" : "",
            timestamp: DateTime(2023));
        print(message.timestamp);
        await FirestoreServices().addMessage(userId, message);
      } catch (e) {
        // print("Error checking database: $e");
      }
    });
  }

  void _listenToDatabaseChanges() async {
    String groupId = await FirestoreServices().getGroupId(userId);

    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .collection('Chats') // Listen to changes in the "Chats" subcollection
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
        .getGroupDetailsById(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      setState(() {});
    }
  }

  void setUserDetails(id) async {
    userDetails = await UserService().getUserDetailsByGroupId();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setMessages();
    // checkDatabasePeriodically();
    // AutoMessageService().sendMessageToDataBasePeriodically();
    setGroupDetails();
    setUserDetails(FirebaseAuth.instance.currentUser!.uid);
    _listenToDatabaseChanges();
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
              backgroundImage: NetworkImage(groupDetails["Image URL"]),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupDetails["Group Name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${groupDetails["Members"].length} members",
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
                              (message) => MessageBubble(message: message)),
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
                  setState(() {
                    _scrollToBottom();
                  });
                  print("Scrolled to bottom");
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

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.senderUserId == FirebaseAuth.instance.currentUser!.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.senderUserId !=
              FirebaseAuth.instance.currentUser!.uid) ...[
            CircleAvatar(
              backgroundImage:
                  NetworkImage(userDetails[message.senderUserId]!["Image URL"]),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.senderUserId == FirebaseAuth.instance.currentUser!.uid
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.senderUserId ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Colors.teal[700]
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: message.isAudio
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomPaint(
                                painter: WaveformPainter(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              message.audioDuration!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')} ${message.timestamp.hour >= 12 ? 'AM' : 'PM'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    const segmentWidth = 3.0;
    const gap = 2.0;
    final segments = (width / (segmentWidth + gap)).floor();

    for (var i = 0; i < segments; i++) {
      final x = i * (segmentWidth + gap);
      final normalizedHeight = _generateRandomHeight(height);
      final startY = (height - normalizedHeight) / 2;
      final endY = startY + normalizedHeight;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  double _generateRandomHeight(double maxHeight) {
    // This is a simplified version - you would want to use actual audio data
    return maxHeight * (0.3 + (DateTime.now().millisecond % 7) / 10);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
