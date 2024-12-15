import 'dart:async';
import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void listenToChatChanges(List<Function> functions, String groupId) async {
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .collection('chats') // Listen to changes in the "Chats" subcollection
        .snapshots()
        .listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added ||
              docChange.type == DocumentChangeType.modified) {
            for (var fn in functions) {
              fn();
            }
          }
        }
      },
      onError: (error) {
        // print("Error listening to database changes: $error");
      },
    );
  }

  void listenToGroupChanges(Function function) async {
    FirebaseFirestore.instance
        .collection('Groups') // Listen to changes in the "Groups" collection
        .snapshots()
        .listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added ||
              docChange.type == DocumentChangeType.modified) {
            function();
          }
        }
      },
      onError: (error) {
        // print("Error listening to database changes: $error");
      },
    );
  }

  Future<Map<String, dynamic>> createGroup(
      Map<String, dynamic> user, Map<String, dynamic> groupData) async {
    try {
      // create group document
      DocumentReference groupDocRef = _firestore.collection('Groups').doc();
      // set the group Data
      await groupDocRef.set(groupData);

      // add the group id and createdOn to the group data
      groupData['groupId'] = groupDocRef.id;
      groupData['createdOn'] =
          DateFormat('MMMM d, yyyy').format(DateTime.now());
      // update the group data after modification
      await groupDocRef.set(groupData);

      // add the group id to the user's data
      user['groups'].add(groupDocRef.id);
      UserService().updateProfile(groupData['members'][0], user);

      return groupData;
    } catch (e) {
      // Use a logging framework instead of print
      // print(e.toString());
    }
    return {};
  }

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

  Future<Map<String, List<Message>>> getChats(String groupId) async {
    Map<String, List<Message>> chatsByDate = {};
    try {
      if (groupId.isNotEmpty) {
        QuerySnapshot chatSnapshots = await _firestore
            .collection('Groups')
            .doc(groupId)
            .collection('chats')
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
              isLog: messageData['isLog'] as bool,
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

  Future<void> addMessage(String groupId, Message message) async {
    try {
      if (groupId.isNotEmpty) {
        DocumentReference chatDocRef = _firestore
            .collection('Groups')
            .doc(groupId)
            .collection('chats')
            .doc(message.timestamp.toIso8601String().split('T').first);

        Map<String, dynamic> messageData = {
          'id': message.id,
          'text': message.text,
          'audioUrl': message.audioUrl,
          'audioDuration': message.audioDuration,
          'senderUserId': message.senderUserId,
          'timestamp': message.timestamp.toIso8601String(),
          'isLog': message.isLog,
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

  Future<Map<String, dynamic>> getGroupDetailsByGroupId(String groupId) async {
    try {
      if (groupId.isNotEmpty) {
        DocumentSnapshot groupSnapshot =
            await _firestore.collection('Groups').doc(groupId).get();
        if (groupSnapshot.exists && groupSnapshot.data() != null) {
          Map<String, dynamic> groupDetails =
              groupSnapshot.data() as Map<String, dynamic>;
          groupDetails['admins'] = List<String>.from(groupDetails['admins']);
          groupDetails['members'] = List<String>.from(groupDetails['members']);
          return groupSnapshot.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
    Map<String, dynamic> defaultGroupDetails = {
      'name': "JamBuds",
      'members': [],
      "chats": {},
      'admins': [],
      "groupId": "",
      "createdOn": DateTime.now().toIso8601String().split('T').first,
    };
    return defaultGroupDetails;
  }

  Future<Map<String, Map<String, dynamic>>> getDetailsOfAllGroups() async {
    Map<String, Map<String, dynamic>> groupDetails = {};
    try {
      CollectionReference groupsCollection = _firestore.collection('Groups');
      QuerySnapshot groupsSnapshot = await groupsCollection.get();
      for (QueryDocumentSnapshot groupDoc in groupsSnapshot.docs) {
        groupDetails[groupDoc.id] = groupDoc.data() as Map<String, dynamic>;
        groupDetails[groupDoc.id]!['admins'] =
            List<String>.from(groupDetails[groupDoc.id]!['admins']);
        groupDetails[groupDoc.id]!['members'] =
            List<String>.from(groupDetails[groupDoc.id]!['members']);
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
    return groupDetails;
  }

  Future<void> updateGroupDetails(
      String groupId, Map<String, dynamic> groupDetails) async {
    try {
      if (groupId.isNotEmpty) {
        await _firestore.collection('Groups').doc(groupId).update(groupDetails);
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      if (groupId.isNotEmpty) {
        await _firestore.collection('Groups').doc(groupId).delete();
      }
    } catch (e) {
      // Use a logging framework instead of print
      // Example: Logger().e(e);
    }
  }
}
