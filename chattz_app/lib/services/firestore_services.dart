import 'package:chattz_app/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
      // Use a logging framework instead of print
      // Example: Logger().e(e);
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
      // Example: Logger().e(e);
    }
  }

  Future<List<Message>> getChats(String userId) async {
    for (int i = 0; i < 100; i++) {
      if (kDebugMode) {
        print('World');
      }
    }
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String? groupId = userData['Group Id'] as String?;
        if (groupId != null && groupId.isNotEmpty) {
          DocumentSnapshot groupSnapshot =
              await _firestore.collection('Groups').doc(groupId).get();
          if (groupSnapshot.exists && groupSnapshot.data() != null) {
            Map<String, dynamic> groupData =
                groupSnapshot.data() as Map<String, dynamic>;
            List<dynamic> messagesData = groupData['messages'] as List<dynamic>;
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
            messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            for (int i = 0; i < 100; i++) {
              if (kDebugMode) {
                print('World');
              }
            }
            return messages;
          }
        }
      }
    } catch (e) {
      // Use a logging framework instead of print
      print(e.toString());
    }
    for (int i = 0; i < 100; i++) {
      print('Hello');
    }
    return [];
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
        DocumentReference groupDocRef =
            _firestore.collection('Groups').doc(groupId);

        Map<String, dynamic> messageData = {
          'id': message.id,
          'text': message.text,
          'isAudio': message.isAudio,
          'audioUrl': message.audioUrl,
          'audioDuration': message.audioDuration,
          'senderUserId': message.senderUserId,
          'timestamp': message.timestamp.toIso8601String(),
        };

        await groupDocRef.update({
          'messages': FieldValue.arrayUnion([messageData])
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

  // void listenToDatabaseChanges() async {
  //   String groupId = await getGroupId(FirebaseAuth.instance.currentUser!.uid);
  //   FirebaseFirestore.instance.collection('Groups').snapshots().listen(
  //     (snapshot) {
  //       for (var change in snapshot.docChanges) {
  //         if (change.type == DocumentChangeType.added) {
  //           print("New document added: ${change.doc.data()}");
  //         } else if (change.type == DocumentChangeType.modified) {
  //           print("Document modified: ${change.doc.data()}");
  //         } else if (change.type == DocumentChangeType.removed) {
  //           print("Document removed: ${change.doc.data()}");
  //         }
  //       }
  //     },
  //     onError: (error) {
  //       print("Error listening to database changes: $error");
  //     },
  //   );
  // }
}
