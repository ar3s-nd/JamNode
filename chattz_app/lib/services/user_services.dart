import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  // add the user info to firestore
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await userCollection.doc(id).set(userInfoMap);
  }

  // update user info in firestore
  Future updateProfile(String id, Map<String, dynamic> updateInfo) async {
    return await userCollection.doc(id).update(updateInfo);
  }

  // get user info from firestore
  Future<Map<String, dynamic>?> getUserDetails(String id) async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(id).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.data() as Map<String, dynamic>?;
    } else {
      Map<String, dynamic> defaultData = {
        'Name': "Name",
        'Email': "Email",
        "College Name": "College Name",
        "College Id": "College Id",
        "Got Details": false
      };
      await userCollection.doc(id).set(defaultData);
      return defaultData;
    }
  }
}
