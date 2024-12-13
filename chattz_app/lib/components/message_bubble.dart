import 'package:chattz_app/components/waveform_painter.dart';
import 'package:chattz_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              backgroundImage: userDetails.containsKey(message.senderUserId)
                  ? NetworkImage(userDetails[message.senderUserId]!["imageUrl"])
                  : NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-wLGEqZy7Akjn0ZMf3qYTxNWZZMMimodTfA&s"),
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
