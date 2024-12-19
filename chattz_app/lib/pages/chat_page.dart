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
    FirestoreServices().listenToChatChanges(
        [setMessages, setGroupDetails, setUserDetails],
        groupDetails['groupId']);
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
          if (mounted) {
            setState(() {
              _showScrollButton = shouldShowButton;
            });
          }
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
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: GestureDetector(
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
          child: Row(
            children: [
              ImageCircle(
                letter: groupDetails['name'][0].toUpperCase(),
                circleRadius: MediaQuery.of(context).size.width *
                    0.045, // Dynamic circle size
                fontSize: MediaQuery.of(context).size.width *
                    0.05, // Dynamic font size
                colors: [Colors.tealAccent.shade200, Colors.teal],
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.02), // Dynamic spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupDetails["name"],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.04, // Dynamic font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      groupDetails['members'].length == 1
                          ? "1 member"
                          : groupDetails['members'].length > 999
                              ? '999+ members'
                              : "${groupDetails['members'].length} members",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: MediaQuery.of(context).size.width *
                            0.03, // Dynamic font size
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                                      ? 'Started on ${groupDetails['createdOn']}'
                                      : 'Started on 2024-12-25',
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
                                            ? 'Started on ${groupDetails['createdOn']}'
                                            : 'Started on 2024-12-25',
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
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.045),
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
                            if (mounted) {
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
                            }
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
                    if (mounted) {
                      setState(() {
                        _scrollToBottom();
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

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
}
