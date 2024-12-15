import 'package:chattz_app/components/image_circle.dart';
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
    final bool isCurrentUser =
        message.senderUserId == FirebaseAuth.instance.currentUser!.uid;
    if (userDetails[message.senderUserId] == null) {
      debugPrint('User details not found for ${message.senderUserId}');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            ImageCircle(
              letter: userDetails[message.senderUserId] != null
                  ? userDetails[message.senderUserId]!['name'][0].toUpperCase()
                  : "P",
              circleRadius: 20,
              fontSize: 20,
              colors: [
                Colors.tealAccent.shade200,
                Colors.teal,
              ],
            ),
            // CircleAvatar(
            //   radius: 20,
            //   backgroundColor: Colors.tealAccent.shade400,
            //   child: Text(
            //     userDetails[message.senderUserId]!['name'][0].toUpperCase() ??
            //         "G",
            //     style: const TextStyle(
            //       color: Colors.black,
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
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
                      color:
                          isCurrentUser ? Colors.teal[700] : Colors.grey[800],
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
