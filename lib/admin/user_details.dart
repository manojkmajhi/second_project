import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:second_project/database/data/local/db_helper.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  List<Map<String, dynamic>> users = [];
  String docPath = '';

  @override
  void initState() {
    super.initState();
    initDirectoryAndFetchUsers();
  }

  // Initialize directory path and fetch users
  Future<void> initDirectoryAndFetchUsers() async {
    final dir = await getApplicationDocumentsDirectory();
    docPath = dir.path;
    await fetchUsers();
  }

  // Fetch users from SQLite
  Future<void> fetchUsers() async {
    final allUsers = await DBHelper.instance.getAllUsers();
    setState(() {
      users = allUsers;
    });
  }

  // Delete user by ID
  Future<void> deleteUser(int userId) async {
    try {
      await DBHelper.instance.deleteUserById(userId);
      await fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting user: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'User Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final String? imagePath = user['image_path'];
                  final File imageFile = File('$docPath/$imagePath');

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (imagePath != null && imageFile.existsSync())
                                ? FileImage(imageFile)
                                : const AssetImage('assets/images/user.png')
                                    as ImageProvider,
                      ),
                      title: Text(user['name'] ?? ''),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text("Delete User"),
                                  content: const Text(
                                    "Are you sure you want to delete this user?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        deleteUser(user['id']);
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
