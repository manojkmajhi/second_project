import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/database/database.dart';
import 'package:second_project/database/shared_preferences.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';
import 'dart:async';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String? userImagePath;
  String? currentUserId; // Firebase User ID (UID)
  final SharedPreferenceHelper _sharedPrefsHelper = SharedPreferenceHelper();

  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _fetchUserData();

    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      debugPrint("Auth state changed detected: User is ${user?.uid ?? 'null'}");

      if (user != null && user.uid != currentUserId) {
        debugPrint("New user detected (${user.uid}). Re-fetching user data...");
        _fetchUserData();
      } else if (user == null && currentUserId != null) {
        debugPrint("User logged out. Resetting profile data...");
        _resetProfileData(); // Clear UI data immediately
      } else if (user != null && user.uid == currentUserId) {
        // Same user logged in, but potentially updated info (e.g., displayName changed).
        // Or, if the widget was rebuilt, ensure data is fresh.
        debugPrint("Same user, re-fetching to ensure data is fresh.");
        _fetchUserData();
      }
      // If user is null and currentUserId is already null, no action needed (already logged out)
    });
  }

  @override
  void dispose() {
    _authStateSubscription
        .cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  // New method to reset all profile data in the UI
  void _resetProfileData() {
    setState(() {
      userName = 'Guest';
      userEmail = 'Not logged in';
      userImagePath = null;
      currentUserId = null;
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Temporarily store fetched data to minimize setState calls
      String fetchedName = user.displayName ?? 'No Name';
      String fetchedEmail = user.email ?? 'No Email';
      String? fetchedImagePath;

      // Update currentUserId immediately to reflect the active user
      setState(() {
        currentUserId = user.uid;
        // Set initial values from Firebase Auth, which might be "Loading..." before Firestore/Local DB fetch
        userName = fetchedName;
        userEmail = fetchedEmail;
        userImagePath = null; // Clear old image path for a fresh fetch
      });

      // Fetch additional user data from Firestore (e.g., custom profile image URL and more accurate name)
      try {
        final docSnapshot = await DatabaseMethods().getUserDetails(user.uid);
        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          fetchedName =
              userData['name']?.toString() ??
              fetchedName; // Prioritize Firestore name
          fetchedImagePath =
              userData['image']?.toString(); // Get image URL from Firestore
          debugPrint(
            "Fetched from Firestore: Name=$fetchedName, Image=$fetchedImagePath",
          );
        } else {
          debugPrint("Firestore document for user ${user.uid} does not exist.");
        }
      } catch (e) {
        debugPrint("Error fetching user data from Firestore: $e");
      }

      // Also try to get image and name from local SQLite if needed (e.g., for offline caching)

      final storedLocalUserId = await _sharedPrefsHelper.getUserId();
      if (storedLocalUserId != null && storedLocalUserId == user.uid) {
        final db = await DBHelper.instance.getDB();
        final result = await db.query(
          "users",
          where: "id = ?",
          whereArgs: [
            int.tryParse(storedLocalUserId) ?? -1,
          ], // Use tryParse and default for safety
        );

        if (result.isNotEmpty) {
          final localUser = result.first;
          // Prioritize Firebase/Firestore image, otherwise use local cached image
          fetchedImagePath = fetchedImagePath ?? localUser['image']?.toString();
          // If name is still generic ('Unknown' or email), try to get it from local DB
          fetchedName =
              (fetchedName == 'Unknown' || fetchedName == user.email)
                  ? localUser['name']?.toString() ?? fetchedName
                  : fetchedName;
          debugPrint(
            "Fetched from local SQLite: Name=${localUser['name']}, Image=${localUser['image']}",
          );
        } else {
          debugPrint("No local SQLite entry found for user ${user.uid}");
        }
      } else {
        debugPrint(
          "Stored local user ID does not match current Firebase UID or is null.",
        );
      }

      // Final update of UI state once all sources have been checked
      if (mounted) {
        setState(() {
          userName = fetchedName;
          userEmail = fetchedEmail;
          userImagePath = fetchedImagePath;
        });
      }
    } else {
      // If no user is logged in, immediately reset UI
      debugPrint("No user currently logged in. Resetting UI.");
      _resetProfileData();
    }
  }

  // Updates both local SQLite and Firestore with the new image path/URL
  Future<void> updateUserImage(File imageFile) async {
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 1. Upload image to Firebase Storage
    String? imageUrl = await DatabaseMethods().uploadImageAndGetUrl(
      imageFile,
      currentUserId!,
    );

    if (imageUrl != null) {
      // 2. Update image URL in Firestore
      await DatabaseMethods().updateUserDetails({
        'image': imageUrl,
      }, currentUserId!);

      // 3. Update image path in local SQLite (store the URL here)
      final storedLocalUserId = await _sharedPrefsHelper.getUserId();
      // Only update local DB if the stored ID matches the current user
      if (storedLocalUserId != null && storedLocalUserId == currentUserId) {
        final db = await DBHelper.instance.getDB();
        await db.update(
          "users",
          {'image': imageUrl},
          where: "id = ?",
          whereArgs: [int.parse(storedLocalUserId)],
        );
      } else {
        debugPrint(
          "Local DB update skipped: storedLocalUserId mismatch or null.",
        );
      }

      setState(() {
        userImagePath = imageUrl; // Update UI with the new image URL
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image for faster upload
    );

    if (pickedFile != null) {
      await updateUserImage(File(pickedFile.path));
    }
  }

  // Updates both local SQLite and Firestore with the new name
  Future<void> updateUserName(String newName) async {
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    //  Update display name in Firebase Auth
    await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);

    // Update name in Firestore
    await DatabaseMethods().updateUserDetails({
      'name': newName,
    }, currentUserId!);

    // Update name in local SQLite
    final storedLocalUserId = await _sharedPrefsHelper.getUserId();
    if (storedLocalUserId != null && storedLocalUserId == currentUserId) {
      // Ensure local ID matches current Firebase ID
      final db = await DBHelper.instance.getDB();
      await db.update(
        "users",
        {'name': newName},
        where: "id = ?",
        whereArgs: [int.parse(storedLocalUserId)],
      );
    } else {
      debugPrint(
        "Local DB name update skipped: storedLocalUserId mismatch or null.",
      );
    }

    setState(() {
      userName = newName;
    });

    if (mounted) {
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
    // Clear user data from SharedPreferences (including the local user ID)
    await _sharedPrefsHelper
        .clearUserData(); // Make sure this clears the USERKEY
    debugPrint(" User data cleared from SharedPreferences");

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    debugPrint(" User signed out from Firebase");

    // Immediately reset UI state before navigating
    _resetProfileData();

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
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ClipOval(
                        child:
                            userImagePath != null && userImagePath!.isNotEmpty
                                ? (userImagePath!.startsWith('http')
                                    ? Image.network(
                                      userImagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Image.asset(
                                            "assets/logo/user.png", // Fallback for network image errors
                                            fit: BoxFit.cover,
                                          ),
                                    )
                                    : Image.file(
                                      File(userImagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Image.asset(
                                            "assets/logo/user.png", // Fallback for local file errors
                                            fit: BoxFit.cover,
                                          ),
                                    ))
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
