import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = '';
  String userEmail = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final db = await DBHelper.getInstance.getDB();
    final List<Map<String, dynamic>> result = await db.query("users");

    if (result.isNotEmpty) {
      setState(() {
        userId = result[0]['id'];
        userName = result[0]['name'];
        userEmail = result[0]['email'];
      });
    }
  }

  Future<void> deleteAccount() async {
    final db = await DBHelper.getInstance.getDB();
    await db.delete("users", where: "id = ?", whereArgs: [userId]);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
      (route) => false,
    );
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "Are you sure you want to delete your account?",
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
      body: Container(
        margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
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
                  child: Image.asset("assets/logo/user.png", fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            _infoCard(Icons.person_2_outlined, 'Name', userName),
            const SizedBox(height: 20.0),
            _infoCard(Icons.email_outlined, 'Email', userEmail),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: showDeleteConfirmation,
              child: _actionCard(Icons.delete_outline, 'Delete Account'),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                  (route) => false,
                );
              },
              child: _actionCard(Icons.logout_outlined, 'Logout'),
            ),
          ],
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
                Text(label, style: AppWidget.lightTextFieldStyle()),
                Text(value, style: AppWidget.semiboldTextFieldStyle()),
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
