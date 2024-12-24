import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/pages/group_details_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  const ChatPage({super.key, required this.groupDetails});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, List<Message>> _messages = {};
  Map<String, dynamic> groupDetails = {};
  bool _showScrollButton = true;
  Map<String, Map<String, dynamic>> userDetails = {};
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  void listenToChatChanges() {
    FirestoreServices().listenToChatChanges(
        [setMessages, setGroupDetails, setUserDetails],
        groupDetails['groupId']);
  }

  void setMessages() async {
    try {
      _messages = await FirestoreServices().getChats(groupDetails['groupId']);
    } catch (e) {
      // handle error
    }
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
    try {
      groupDetails = await FirestoreServices()
          .getGroupDetailsByGroupId(groupDetails['groupId']);
    } catch (e) {
      // handle error
    }
    if (mounted) {
      setState(() {});
    }
  }

  void setUserDetails() async {
    try {
      userDetails =
          await UserService().getUserDetailsByGroupId(groupDetails['groupId']);
    } catch (e) {
      // handle error
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final shouldShowButton = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 100;

      if (shouldShowButton != _showScrollButton) {
        if (mounted) {
          setState(() {
            _showScrollButton = shouldShowButton;
          });
        }
        if (_showScrollButton) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      }
    }
  }

  void initialiseChat() {
    _scrollController.addListener(_scrollListener);
    setGroupDetails();
    setUserDetails();
    setMessages();
    listenToChatChanges();
  }

  @override
  void initState() {
    super.initState();
    initialiseChat();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAnimatedAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade900, Colors.black],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _messages.keys.isEmpty
                      ? _buildEmptyState()
                      : _buildMessageList(),
                ),
                _buildInputTextField(),
              ],
            ),
            if (_showScrollButton) _buildScrollToBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0.0, -kToolbarHeight * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: AppBar(
          backgroundColor: Colors.grey.shade900,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                FadePageRoute(
                  page: GroupDetailsPage(
                    groupDetails: groupDetails,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: 'group-${groupDetails['groupId']}',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade700.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        groupDetails['name'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupDetails["name"],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        groupDetails['members'].length == 1
                            ? "1 member"
                            : "${groupDetails['members'].length} members",
                        style: TextStyle(
                          color: Colors.teal.shade200,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () {
                // Group options menu
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      right: 16,
      bottom: 80,
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.teal.shade700,
          onPressed: _scrollToBottom,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.withOpacity(0.2)),
            ),
            child: Text(
              groupDetails.containsKey('createdOn')
                  ? 'Started on ${groupDetails['createdOn']}'
                  : 'New Group Created',
              style: TextStyle(
                color: Colors.teal.shade200,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first one to send a message!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.keys.length,
      itemBuilder: (context, index) {
        final date = _messages.keys.elementAt(index);
        final messages = _messages[date]!
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return Column(
          children: [
            if (index == 0) _buildGroupCreationBanner(),
            _buildDateHeader(date),
            // ...messages.map((message) => _buildMessageBubble(message)),
            ...messages.map((message) => MessageBubble(
                message: message,
                userDetails: userDetails[message.senderUserId] ?? {})),
          ],
        );
      },
    );
  }

  Widget _buildGroupCreationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        groupDetails.containsKey('createdOn')
            ? '✨ Started on ${groupDetails['createdOn']}'
            : '✨ Welcome to the Jam!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          DateFormat("MMMM d, yyyy").format(DateTime.parse(date)),
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInputTextField() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // IconButton(
          //   icon: Icon(Icons.add_circle_outline, color: Colors.teal.shade200),
          //   onPressed: () {
          //     // Add attachment functionality
          //   },
          // ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade500, fontWeight: FontWeight.w300),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: value.text.isEmpty
                      ? Colors.transparent
                      : Colors.teal.shade700,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: value.text.isEmpty
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      final message = Message(
                        id: DateTime.now().toString(),
                        text: _messageController.text,
                        senderUserId: userId,
                        timestamp: DateTime.now(),
                      );
                      FirestoreServices()
                          .addMessage(groupDetails['groupId'], message);
                      _messageController.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              );
            },
          ),
        ],
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
