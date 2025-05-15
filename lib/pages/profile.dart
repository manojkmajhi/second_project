import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/database/database.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = '';
  String userEmail = '';
  String? userImagePath;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    debugPrint("userId from SharedPreferences: $userId");

    if (userId != null) {
      final db = await DBHelper.instance.getDB();
      final result = await db.query(
        "users",
        where: "id = ?",
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        final user = result.first;
        setState(() {
          userName = user['name']?.toString() ?? 'Unknown';
          userEmail = user['email']?.toString() ?? 'Unknown';
          userImagePath = user['image']?.toString();
        });
      }
    }
  }

  Future<void> updateUserImage(String imagePath) async {
    if (userId != null) {
      final db = await DBHelper.instance.getDB();
      await db.update(
        "users",
        {'image': imagePath},
        where: "id = ?",
        whereArgs: [userId],
      );
      setState(() {
        userImagePath = imagePath;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await DatabaseMethods().updateUserDetails({
          'image': imagePath,
        }, currentUser.uid);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      await updateUserImage(pickedFile.path);
    }
  }

  Future<void> updateUserName(String newName) async {
    if (userId != null) {
      final db = await DBHelper.instance.getDB();
      await db.update(
        "users",
        {'name': newName},
        where: "id = ?",
        whereArgs: [userId],
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await DatabaseMethods().updateUserDetails({
          'name': newName,
        }, currentUser.uid);
      }

      setState(() {
        userName = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showEditNameDialog() {
    final nameController = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Name"),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    updateUserName(newName);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(),
                      ),
                      child: ClipOval(
                        child:
                            userImagePath != null && userImagePath!.isNotEmpty
                                ? Image.file(
                                  File(userImagePath!),
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  "assets/logo/user.png",
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: showEditNameDialog,
                child: _infoCard(
                  Icons.person_2_outlined,
                  'Name',
                  userName,
                  editable: true,
                ),
              ),
              const SizedBox(height: 20.0),
              _infoCard(Icons.email_outlined, 'Email', userEmail),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: logout,
                child: _actionCard(Icons.logout_outlined, 'Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String label,
    String value, {
    bool editable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      width: double.infinity,
      child: Row(
        children: [
          Icon(icon, size: 30.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (editable) const Icon(Icons.edit_outlined, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Icon(icon, size: 30.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(title, style: AppWidget.semiboldTextFieldStyle()),
          ),
          const Icon(Icons.arrow_forward_ios_outlined),
        ],
      ),
    );
  }
}
