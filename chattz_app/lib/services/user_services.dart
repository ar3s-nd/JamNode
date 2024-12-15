import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  // add the user info to firestore
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await userCollection.doc(id).set(userInfoMap);
  }

  // update user info in firestore
  Future updateProfile(String id, Map<String, dynamic> userInfoMap) async {
    return await userCollection.doc(id).update(userInfoMap);
  }

  // get user info from firestore
  Future<Map<String, dynamic>> getUserDetailsById(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await userCollection.doc(id).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        return {
          'collegeId': 'collegeId',
          'collegeName': 'College Name',
          'email': 'Email',
          'name': 'name',
          'gotDetails': false,
          'group': [],
          'roles': [],
        };
      }
    } catch (e) {}
    return Future.value({
      'collegeId': 'College Id',
      'collegeName': 'College Name',
      'email': 'Email',
      'name': 'name',
      'gotDetails': false,
      'groups': [],
      'roles': [],
    });
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
      }
      return userMap;
    } catch (e) {}
    return {};
  }
}
