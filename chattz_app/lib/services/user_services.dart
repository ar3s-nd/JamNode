import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  // add the user info to firestore
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await userCollection.doc(id).set(userInfoMap);
  }

  // update user info in firestore
  Future updateProfile(String id, Map<String, dynamic> userInfoMap) async {
    debugPrint('at updateProfile ${userInfoMap['name']}');
    debugPrint('${userInfoMap['groups']}');
    return await userCollection.doc(id).update(userInfoMap);
  }

  Map<String, dynamic> parse(Map<String, dynamic>? data) {
    if (data == null) {
      return {
        'uid': '123',
        'collegeId': 'College Id',
        'collegeName': 'College Name',
        'email': 'Email',
        'name': 'name',
        'gotDetails': false,
        'groups': [],
        'skills': {},
      };
    }
    data['uid'] = data['uid'] as String;
    data['collegeId'] = data['collegeId'] as String? ?? '';
    data['collegeName'] = data['collegeName'] as String? ?? '';
    data['email'] = data['email'] as String? ?? '';
    data['name'] = data['name'] as String? ?? '';
    data['gotDetails'] = data['gotDetails'] as bool? ?? false;
    data['groups'] = List<String>.from(data['groups'] ?? ['hello moto']);
    data['skills'] = Map<String, int>.from(data['skills'] ?? {});
    debugPrint('at parse ${data['name']}');
    debugPrint(data['groups'].toString());
    Map<String, int> sortedMap = Map.fromEntries(
      data['skills'].entries.toList()
        ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.key.compareTo(b.key)),
    );
    data['skills'] = sortedMap;
    return data;
  }

  // get user info from firestore
  Future<Map<String, dynamic>> getUserDetailsById(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await userCollection.doc(id).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        // debugPrint(parse(data).toString());
        return parse(data);
      } else {
        return {
          'uid': '123',
          'collegeId': 'collegeId',
          'collegeName': 'College Name',
          'email': 'Email',
          'name': 'name',
          'gotDetails': false,
          'groups': [],
          'skills': {},
        };
      }
    } catch (e) {
      //  Use a logging framework instead of print
    }
    return Future.value(
      {
        'uid': '123',
        'collegeId': 'College Id',
        'collegeName': 'College Name',
        'email': 'Email',
        'name': 'name',
        'gotDetails': false,
        'groups': [],
        'skills': {},
      },
    );
  }

  // get user info from firestore by groupId
  Future<Map<String, Map<String, dynamic>>> getUserDetailsByGroupId(
      String groupId) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('groups', arrayContains: groupId).get();
      Map<String, Map<String, dynamic>> userMap = {};
      for (var element in querySnapshot.docs) {
        userMap[element.id] =
            Map<String, dynamic>.from(element.data() as Map<String, dynamic>);
        userMap[element.id] = parse(userMap[element.id]);
      }
      return userMap;
    } catch (e) {
      // Use a logging framework instead of print
      debugPrint(e.toString());
    }
    return Future.value(
      {
        'user1': {
          'collegeId': 'College Id',
          'uid': '123',
          'collegeName': 'College Name',
          'email': 'Email',
          'name': 'name',
          'gotDetails': false,
          'groups': [],
          'skills': {},
        }
      },
    );
  }
}
