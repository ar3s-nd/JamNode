import 'dart:async';
import 'dart:math';

import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutoMessageService {
  String generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return List.generate(length, (index) {
      int randomIndex = random.nextInt(characters.length);
      return characters[randomIndex];
    }).join();
  }

  void sendMessageToDataBasePeriodically({int time = 5, String? userId}) {
    userId ??= FirebaseAuth.instance.currentUser!.uid;
    Timer.periodic(Duration(seconds: time), (timer) async {
      try {
        Message message = Message(
            id: DateTime.now().toString(),
            text: generateRandomString(20),
            senderUserId: userId,
            timestamp: DateTime(2023));
        await FirestoreServices().addMessage(userId!, message);
      } catch (e) {
        // Use a logging framework instead of print
      }
    });
  }
}
