import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  // add the user info to firestore
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(id)
        .set(userInfoMap);
  }

  // update user info in firestore
  Future updateProfile(String id, Map<String, dynamic> updateInfo) async {
    return await userCollection.doc(id).update(updateInfo);
  }
}
