import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Map<String, Map<String, dynamic>> userDetails;

  const MessageBubble({
    super.key,
    required this.message,
    required this.userDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        message.senderUserId == FirebaseAuth.instance.currentUser!.uid;

    String text = message.text;
    if (message.isLog) {
      String userName = text.split(' ')[0];
      text = isCurrentUser
          ? text.contains('joined')
              ? 'You want to jam with others'
              : 'You were too busy to jam with the others'
          : text.contains('joined')
              ? '$userName wants to jam with you'
              : '$userName was too busy to jam with you';
    }

    ProfanityFilter filter = ProfanityFilter();
    text = filter.censor(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: message.isLog
          ? Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser) ...[
                  ImageCircle(
                    letter: userDetails[message.senderUserId] != null
                        ? userDetails[message.senderUserId]!['name'][0]
                            .toUpperCase()
                        : 'P',
                    circleRadius: 20,
                    fontSize: 20,
                    colors: [
                      Colors.tealAccent.shade200,
                      Colors.teal,
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width *
                          0.6, // 60% of the screen width
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.teal[700]
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: isCurrentUser
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: Text(
                            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')} ${message.timestamp.hour <= 12 ? 'AM' : 'PM'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
