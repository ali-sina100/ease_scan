// this class provides the user data repository from firebase
// this statment import FirbaseFirestore to this file
 import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_data.dart';

class UserDataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This method returns the user data from the firestore
  Future<UserData> getUserData(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(uid).get();

    return UserData.fromMap(userDoc.data()!);
  }

  // This method updates the user data in the firestore
  Future<void> updateUserData(UserData userData) async {
    await _firestore.collection('users').doc(userData.uid).set(userData.toMap());
  }
}