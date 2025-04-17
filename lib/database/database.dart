import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Add user details to Firestore
  Future addUserDetails(Map<String, dynamic> userInfoMap, String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  // Delete user from Firestore
  Future deleteUserFromFirestore(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .delete();
  }

  // Update user details in Firestore
  Future updateUserDetails(Map<String, dynamic> updatedData, String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(updatedData);
  }
  
}
