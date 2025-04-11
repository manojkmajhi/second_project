import 'package:cloud_firestore/cloud_firestore.dart';



class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }
}
