import 'dart:async';

import 'package:chattz_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getRoles() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Roles').get();
      List<String> roles = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['role'] as String)
          .toList();
      return roles;
    } catch (e) {
      return [];
    }
  }

// Future<void> addRoles(List<String> roles) async {
  Future<void> addRoles(
      List<String> roles, String collectionId, String fieldId) async {
    try {
      WriteBatch batch = _firestore.batch();
      CollectionReference rolesCollection = _firestore.collection(collectionId);

      for (String role in roles) {
        DocumentReference docRef = rolesCollection.doc();
        batch.set(docRef, {fieldId: role});
      }

      await batch.commit();
    } catch (e) {
      // Use a logging framework instead of print
      // print(e.toString());
    }
  }

  Future<Map<String, List<Message>>> getChats(String userId) async {
    Map<String, List<Message>> chatsByDate = {};
    try {
      String groupId = await getGroupId(userId);
      if (groupId.isNotEmpty) {
        QuerySnapshot chatSnapshots = await _firestore
            .collection('Groups')
            .doc(groupId)
            .collection('Chats')
            .get();

        for (QueryDocumentSnapshot chatDoc in chatSnapshots.docs) {
          String date = chatDoc.id;
          Map<String, dynamic> chatData =
              chatDoc.data() as Map<String, dynamic>;
          List<dynamic> messagesData = chatData['message'] as List<dynamic>;

          List<Message> messages = messagesData.map((messageData) {
            return Message(
              id: messageData['id'] as String,
              text: messageData['text'] as String,
              isAudio: messageData['isAudio'] as bool,
              audioUrl: messageData['audioUrl'] as String?,
              audioDuration: messageData['audioDuration'] as String?,
              senderUserId: messageData['senderUserId'] as String?,
              timestamp: DateTime.parse(messageData['timestamp'] as String),
            );
          }).toList();
          chatsByDate[date] = messages;
        }
      }
    } catch (e) {
      // Use a logging framework instead of print
      // print(e.toString());
    }

    return chatsByDate;
  }

  Future<void> updateChat(String userId, List<Message> messages) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String? groupId = userData['Group Id'] as String?;
        if (groupId != null && groupId.isNotEmpty) {
          DocumentReference groupDocRef =
              _firestore.collection('Groups').doc(groupId);

          List<Map<String, dynamic>> messagesData = messages.map((message) {
            return {
              'id': message.id,
              'text': message.text,
              'isAudio': message.isAudio,
              'audioUrl': message.audioUrl,
              'audioDuration': message.audioDuration,
              'senderUserId': message.senderUserId,
              'timestamp': message.timestamp.toIso8601String(),
            };
          }).toList();

          await groupDocRef.set({
            'messages': messagesData,
            "updatedAt": DateTime.now().toIso8601String()
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
  }

  Future<void> addMessage(String userId, Message message) async {
    try {
      String groupId = await getGroupId(userId);
      if (groupId.isNotEmpty) {
        String date = message.timestamp.toIso8601String().split('T').first;

        DocumentReference chatDocRef = _firestore
            .collection('Groups')
            .doc(groupId)
            .collection('Chats')
            .doc(date);

        Map<String, dynamic> messageData = {
          'id': message.id,
          'text': message.text,
          'isAudio': message.isAudio,
          'audioUrl': message.audioUrl,
          'audioDuration': message.audioDuration,
          'senderUserId': message.senderUserId,
          'timestamp': message.timestamp.toIso8601String(),
        };

        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot chatDocSnapshot = await transaction.get(chatDocRef);
          if (chatDocSnapshot.exists) {
            transaction.update(chatDocRef, {
              'message': FieldValue.arrayUnion([messageData])
            });
          } else {
            transaction.set(chatDocRef, {
              'message': [messageData]
            });
          }
        });
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
  }

  Future<String> getGroupId(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String? groupId = userData['Group Id'] as String?;
        return groupId ?? '';
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
    return '';
  }

  Future<Map<String, dynamic>> getGroupDetailsById(String userId) async {
    try {
      String groupId = await getGroupId(userId);
      if (groupId.isNotEmpty) {
        DocumentSnapshot groupSnapshot =
            await _firestore.collection('Groups').doc(groupId).get();
        if (groupSnapshot.exists && groupSnapshot.data() != null) {
          return groupSnapshot.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
    return <String, dynamic>{}; // Return an empty map if there is an error
  }
}
