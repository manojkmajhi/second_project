import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      debugPrint("SQLite user query result: $result");

      if (result.isNotEmpty) {
        final user = result.first;
        setState(() {
          userName = user['name']?.toString() ?? 'Unknown';
          userEmail = user['email']?.toString() ?? 'Unknown';
        });
      } else {
        debugPrint("No user found with ID: $userId");
      }
    } else {
      debugPrint(" user_id not found in SharedPreferences");
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

      // Update Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await DatabaseMethods().updateUserDetails({'name': newName}, currentUser.uid);
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
      builder: (context) => AlertDialog(
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

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final db = await DBHelper.instance.getDB();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (userId != null) {
      await db.delete("users", where: "id = ?", whereArgs: [userId]);
    }

    if (currentUser != null) {
      try {
        await DatabaseMethods().deleteUserFromFirestore(currentUser.uid);
        await currentUser.delete();
      } catch (e) {
        debugPrint("Error deleting user from Firebase: $e");
      }
    }

    await prefs.remove('user_id');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
      (route) => false,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
      (route) => false,
    );
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAccount();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(),
                  ),
                  height: 120,
                  width: 120,
                  child: ClipOval(
                    child: Image.asset(
                      "assets/logo/user.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: showEditNameDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person_2_outlined, size: 30.0),
                        const SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Name', style: TextStyle(color: Colors.grey)),
                            Text(
                              userName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_outlined, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _infoCard(Icons.email_outlined, 'Email', userEmail),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: showDeleteConfirmation,
                child: _actionCard(Icons.delete_outline, 'Delete Account'),
              ),
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

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      width: MediaQuery.of(context).size.width,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Icon(icon, size: 30.0),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 30.0),
                const SizedBox(width: 10.0),
                Text(title, style: AppWidget.semiboldTextFieldStyle()),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_outlined),
          ],
        ),
      ),
    );
  }
}
