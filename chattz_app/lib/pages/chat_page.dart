import 'dart:async';
import 'dart:math';
import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/pages/group_details_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String generateRandomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return List.generate(length, (index) {
    int randomIndex = random.nextInt(characters.length);
    return characters[randomIndex];
  }).join();
}

Map<String, Map<String, dynamic>> userDetails = {};

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  const ChatPage({super.key, required this.groupDetails});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, List<Message>> _messages = {};
  Map<String, dynamic> groupDetails = {};
  bool _showScrollButton = true;

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
        await FirestoreServices().addMessage(groupDetails['groupId'], message);
      } catch (e) {
        // print("Error checking database: $e");
      }
    });
  }

  void listenToChatChanges() {
    FirestoreServices()
        .listenToChatChanges([setMessages], groupDetails['groupId']);
  }

  void setMessages() async {
    _messages = await FirestoreServices().getChats(groupDetails['groupId']);
    if (mounted) {
      setState(() {});
    }
  }

  void setGroupDetails() async {
    if (mounted && groupDetails.isEmpty) {
      setState(() {
        groupDetails = widget.groupDetails;
      });
    }
    groupDetails = await FirestoreServices()
        .getGroupDetailsByGroupId(groupDetails['groupId']);
    if (mounted) {
      setState(() {});
    }
    // debugPrint("Group Details: ${groupDetails.toString()}");
    // debugPrint("Widget Group Details: ${widget.groupDetails.toString()}");
    debugPrint("${groupDetails['chats'] == widget.groupDetails['chats']}");
    debugPrint(_messages.toString());
  }

  void setUserDetails() async {
    userDetails =
        await UserService().getUserDetailsByGroupId(groupDetails['groupId']);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // checkDatabasePeriodically();
    // AutoMessageService().sendMessageToDataBasePeriodically();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        // Show button only if not at the bottom
        final shouldShowButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent - 100;

        if (shouldShowButton != _showScrollButton) {
          setState(() {
            _showScrollButton = shouldShowButton;
          });
        }
      }
    });
    setGroupDetails();
    setUserDetails();
    setMessages();
    listenToChatChanges();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (groupDetails.isEmpty) {
      setGroupDetails();
    }
    if (userDetails.isEmpty) {
      setUserDetails();
    }
    if (_messages.isEmpty) {
      setMessages();
      debugPrint("Messages: $_messages");
    }
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
            ImageCircle(
              letter: groupDetails['name'][0].toUpperCase(),
              circleRadius: 20,
              fontSize: 20,
              colors: [Colors.teal.shade400, Colors.teal],
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsPage(
                      groupDetails: groupDetails,
                    ),
                  ),
                );
              },
              child: Column(
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
                  child: _messages.keys.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  groupDetails.containsKey('createdOn')
                                      ? 'Created on ${groupDetails['createdOn']}'
                                      : 'Created on 2024-12-25',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.keys.length,
                          itemBuilder: (context, index) {
                            final date = _messages.keys.elementAt(index);
                            debugPrint("Date: $date");
                            debugPrint(
                                "messages: ${_messages.keys.elementAt(index)}");
                            debugPrint("Date: ${DateTime.now()}");

                            final messages = _messages[date]!;
                            // Sort the messages by timestamp
                            messages.sort(
                              (a, b) => a.timestamp.compareTo(b.timestamp),
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0)
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        groupDetails.containsKey('createdOn')
                                            ? 'Created on ${groupDetails['createdOn']}'
                                            : 'Created on 2024-12-25',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Displaying date above the messages
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      DateFormat("MMMM d, yyyy")
                                          .format(DateTime.parse(date)),
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
                                      userDetails: userDetails,
                                      message: message),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.01,
                    // maxHeight: 150,
                  ),
                  child: Row(
                    children: [
                      // Mic Button
                      IconButton(
                        icon:
                            const Icon(Icons.mic_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                      // TextField for input
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null, // Allows multiline input
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Write your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w300,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Send Button
                      IconButton(
                        icon:
                            const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            setState(() {
                              Message message = Message(
                                id: DateTime.now().toString(),
                                text: _messageController.text,
                                senderUserId: userId,
                                timestamp: DateTime.now(),
                              );
                              String date = message.timestamp.toString();
                              if (_messages.containsKey(date)) {
                                _messages[date]!.add(message);
                              } else {
                                _messages[date] = [message];
                              }
                              FirestoreServices().addMessage(
                                groupDetails['groupId'],
                                message,
                              );
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
            if (_showScrollButton)
              Positioned(
                bottom: MediaQuery.of(context).size.height *
                    0.1, // 10% of the screen height
                right: MediaQuery.of(context).size.width *
                    0.02, // 2% of the screen width
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_downward_rounded),
                  onPressed: () {
                    setState(() {
                      _scrollToBottom();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // void _scrollToBottom() {
  //   // Get the height of the screen and the height of the keyboard
  //   double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  //   // Scroll to the bottom of the chat, but account for the keyboard height
  //   double targetPosition = _scrollController.position.maxScrollExtent;
  //   if (keyboardHeight > 0) {
  //     targetPosition -=
  //         keyboardHeight; // Adjust scroll position if the keyboard is visible
  //   }

  //   // Animate scroll to the target position
  //   _scrollController.animateTo(
  //     targetPosition,
  //     duration: const Duration(milliseconds: 600),
  //     curve: Curves.easeOut,
  //   );
  // }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    // Ensures the code runs only after the current frame is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
