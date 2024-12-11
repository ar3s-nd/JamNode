import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;
  final bool isAudio;
  final String? audioUrl;
  final String audioDuration;
  final bool isSender;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    this.isAudio = false,
    this.audioUrl,
    this.audioDuration = "00:00",
    required this.isSender,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [
    Message(
      id: '1',
      text: "Hello! Jhon abraham",
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Message(
      id: '2',
      text: "Hello ! Nazrul How are you?",
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Message(
      id: '3',
      text: "You did your job well!",
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    Message(
      id: '4',
      text: "Have a great working week!!",
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Message(
      id: '5',
      text: "Hope you like it",
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    Message(
      id: '6',
      isAudio: true,
      text: "",
      audioDuration: "00:16",
      isSender: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jhon Abraham',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Active now',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showDate = index == 0 ||
                    !_isSameDay(
                        _messages[index - 1].timestamp, message.timestamp);

                return Column(
                  children: [
                    if (showDate) ...[
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
                            'Today',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    MessageBubble(message: message),
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
                  icon: const Icon(Icons.mic_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write your message',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  color: Colors.white,
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.add(Message(
                          id: DateTime.now().toString(),
                          text: _messageController.text,
                          isSender: true,
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
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
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
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSender) ...[
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        message.isSender ? Colors.teal[700] : Colors.grey[800],
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
                              message.audioDuration,
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
