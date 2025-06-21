import 'dart:io'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; 

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  final FirebaseStorage _storage = FirebaseStorage.instance;

  
  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String userId) async {
    return await _firestore.collection("users").doc(userId).set(userInfoMap);
  }

 
  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await _firestore.collection("users").doc(userId).get();
  }

  Future<void> updateUserDetails(Map<String, dynamic> updatedData, String userId) async {
    return await _firestore.collection("users").doc(userId).update(updatedData);
  }


  Future<void> deleteUserFromFirestore(String userId) async {
    return await _firestore.collection("users").doc(userId).delete();
  }

  
  Future<String?> uploadImageAndGetUrl(File imageFile, String userId) async {
    try {
      
      String fileName = 'profile_images/$userId/${const Uuid().v4()}.jpg';

     
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);

     
      TaskSnapshot snapshot = await uploadTask;

    
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
    
      debugPrint("Error uploading image to Firebase Storage: $e");
      return null; 
    }
  }


  Future<DocumentReference<Map<String, dynamic>>> addProduct(Map<String, dynamic> productInfoMap) async {
    return await _firestore.collection("products").add(productInfoMap);
  }


  Stream<QuerySnapshot> getProducts() {
    return _firestore.collection("products").snapshots();
  }


  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _firestore.collection("products").where("category", isEqualTo: category).snapshots();
  }

  Future<void> updateProductDetails(String productId, Map<String, dynamic> updatedData) async {
    return await _firestore.collection("products").doc(productId).update(updatedData);
  }


  Future<void> deleteProduct(String productId) async {
    return await _firestore.collection("products").doc(productId).delete();
  }

 
}