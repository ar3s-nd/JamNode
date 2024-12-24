import 'package:chattz_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Map<String, dynamic> userDetails;

  const MessageBubble({
    super.key,
    required this.message,
    required this.userDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        message.senderUserId == FirebaseAuth.instance.currentUser!.uid;
    final String text = _getMessageText(isCurrentUser);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: message.isLog
            ? _buildLogMessage(text)
            : _buildChatMessage(context, isCurrentUser, text),
      ),
    );
  }

  String _getMessageText(bool isCurrentUser) {
    if (message.isLog) {
      final String userName = message.text.split(' ')[0];
      return isCurrentUser
          ? message.text.contains('joined')
              ? 'You want to jam with others'
              : 'You were too busy to jam with the others'
          : message.text.contains('joined')
              ? '$userName wants to jam with you'
              : '$userName was too busy to jam with you';
    }
    return message.text;
  }

  Widget _buildLogMessage(String text) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(
      BuildContext context, bool isCurrentUser, String text) {
    final isSender =
        message.senderUserId == FirebaseAuth.instance.currentUser!.uid;
    final user = userDetails;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal.shade700,
                child: Text(
                  user['name']?[0].toUpperCase() ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(
                begin: Offset(isSender ? 1.0 : -1.0, 0.0),
                end: Offset.zero,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset * 20,
                  child: Opacity(
                    opacity: 1 - offset.dx.abs(),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSender ? Colors.teal.shade700 : Colors.grey.shade800,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isSender ? 20 : 4),
                    bottomRight: Radius.circular(isSender ? 4 : 20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSender)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          user['name'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.teal.shade200,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: isSender ? Colors.white70 : Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
