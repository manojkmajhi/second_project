import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:second_project/database/data/local/db_helper.dart'; // Ensure this path is correct
import 'package:second_project/database/database.dart'; // Ensure this path is correct
import 'package:second_project/database/shared_preferences.dart'; // Ensure this path is correct
import 'package:second_project/pages/authentication/signin/signin.dart'; // Ensure this path is correc
import 'package:second_project/pages/profile/model/user_profile_model.dart';
import 'package:second_project/pages/profile/widget/profile_action_card.dart';
import 'package:second_project/pages/profile/widget/profile_info_card.dart';

import 'package:second_project/widget/support_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure this path is correct if AppWidget is used

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel _userProfile =
      UserProfileModel(name: 'Loading...', email: 'Loading...');
  String? _currentUserId;
  late StreamSubscription<User?> _authStateSubscription;

  final SharedPreferenceHelper _sharedPrefsHelper = SharedPreferenceHelper();
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.uid != _currentUserId) {
        _fetchUserData();
      } else if (user == null && _currentUserId != null) {
        _resetProfileData();
      } else if (user != null && user.uid == _currentUserId) {
        // User is still logged in and the same, re-fetch to ensure fresh data
        _fetchUserData();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _resetProfileData() {
    setState(() {
      _userProfile = UserProfileModel(name: 'Guest', email: 'Not logged in');
      _currentUserId = null;
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fetchedName = user.displayName ?? 'Update name';
      String fetchedEmail = user.email ?? 'No email';
      String? fetchedImagePath;

      // 1. First check local file system
      fetchedImagePath = await _getLocalImagePath(user.uid);

      // 2. Check SharedPreferences for cached URL
      if (fetchedImagePath == null) {
        fetchedImagePath = await _sharedPrefsHelper.getUserImage();
      }

      // 3. Check local SQLite database
      if (fetchedImagePath == null) {
        final storedLocalUserId = await _sharedPrefsHelper.getUserId();
        if (storedLocalUserId != null && storedLocalUserId == user.uid) {
          final db = await DBHelper.instance.getDB();
          final result = await db.query(
            "users",
            where: "id = ?",
            whereArgs: [int.tryParse(storedLocalUserId) ?? -1],
          );

          if (result.isNotEmpty) {
            final localUser = result.first;
            if (localUser['image'] != null && localUser['image'].toString().isNotEmpty) {
              fetchedImagePath = localUser['image'].toString();
            }
            fetchedName = localUser['name']?.toString() ?? fetchedName;
          }
        }
      }

      if (mounted) {
        setState(() {
          _currentUserId = user.uid;
          _userProfile = UserProfileModel(
            name: fetchedName,
            email: fetchedEmail,
            imagePath: fetchedImagePath,
          );
        });
      }

      // 4. Check Firestore for most recent data (in background)
      try {
        final docSnapshot = await _databaseMethods.getUserDetails(user.uid);
        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          final firestoreName = userData['name']?.toString();
          final firestoreImageUrl = userData['image']?.toString();

          bool hasChanges = false;

          if (firestoreName != null && firestoreName != fetchedName) {
            fetchedName = firestoreName;
            hasChanges = true;
          }

          if (firestoreImageUrl != null && firestoreImageUrl != fetchedImagePath) {
            if (firestoreImageUrl.startsWith('http')) {
              final cachedPath = await _cacheNetworkImage(firestoreImageUrl, user.uid);
              if (cachedPath != null) {
                fetchedImagePath = cachedPath;
                hasChanges = true;
              }
            } else {
              fetchedImagePath = firestoreImageUrl;
              hasChanges = true;
            }

            // Update local storage
            final storedLocalUserId = await _sharedPrefsHelper.getUserId();
            if (storedLocalUserId != null && storedLocalUserId == user.uid) {
              final db = await DBHelper.instance.getDB();
              await db.update(
                "users",
                {'image': fetchedImagePath, 'name': fetchedName},
                where: "id = ?",
                whereArgs: [int.parse(storedLocalUserId)],
              );
              await _sharedPrefsHelper.saveUserImage(fetchedImagePath!);
              await _sharedPrefsHelper.saveUserName(fetchedName);
            }
          }

          if (hasChanges && mounted) {
            setState(() {
              _userProfile = UserProfileModel(
                name: fetchedName,
                email: fetchedEmail,
                imagePath: fetchedImagePath,
              );
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching from Firestore: $e");
      }
    } else {
      _resetProfileData();
    }
  }

  Future<String?> _cacheNetworkImage(String url, String userId) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/user_$userId.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error caching network image: $e');
    }
    return null;
  }

  Future<String?> _getLocalImagePath(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/user_$userId.jpg';

      if (await File(imagePath).exists()) {
        return imagePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local image path: $e');
      return null;
    }
  }

  Future<void> _deleteLocalImage(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/user_$userId.jpg';

      if (await File(imagePath).exists()) {
        await File(imagePath).delete();
      }
    } catch (e) {
      debugPrint('Error deleting local image: $e');
    }
  }

  Future<void> _updateUserImage(File imageFile) async {
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to update profile image'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!await imageFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected image file is invalid'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading image...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 1. Save locally
      final localImagePath = await _saveImageLocally(
        imageFile,
        _currentUserId!,
      );

      // Update UI immediately with local image
      if (localImagePath != null && mounted) {
        setState(() {
          _userProfile = _userProfile.copyWith(imagePath: localImagePath);
        });
      }

      // 2. Upload to Firebase Storage (in background)
      final imageUrl = await _databaseMethods.uploadImageAndGetUrl(
        imageFile,
        _currentUserId!,
      );

      if (imageUrl != null) {
        // 3. Update Firestore
        await _databaseMethods.updateUserDetails({
          'image': imageUrl,
        }, _currentUserId!);

        // 4. Update local preferences
        await _sharedPrefsHelper.saveUserImage(imageUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image saved locally but upload failed: ${e.toString()}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<String?> _saveImageLocally(File imageFile, String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/user_$userId.jpg';
      await imageFile.copy(imagePath);
      return imagePath;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      await _updateUserImage(File(pickedFile.path));
    }
  }

  Future<void> _updateUserName(String newName) async {
    if (_currentUserId == null) return;

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      await _databaseMethods.updateUserDetails({
        'name': newName,
      }, _currentUserId!);

      final storedLocalUserId = await _sharedPrefsHelper.getUserId();
      if (storedLocalUserId != null && storedLocalUserId == _currentUserId) {
        final db = await DBHelper.instance.getDB();
        await db.update(
          "users",
          {'name': newName},
          where: "id = ?",
          whereArgs: [int.parse(storedLocalUserId)],
        );
        await _sharedPrefsHelper.saveUserName(newName);
      }

      setState(() {
        _userProfile = _userProfile.copyWith(name: newName);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      }
    } catch (e) {
      debugPrint("Error updating name: $e");
    }
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userProfile.name);
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
                _updateUserName(newName);
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (_currentUserId != null) {
      await _deleteLocalImage(_currentUserId!);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
    await FirebaseAuth.instance.signOut();
    _resetProfileData();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
      (route) => false,
    );
  }

  Widget _buildProfileImage() {
    if (_userProfile.imagePath == null || _userProfile.imagePath!.isEmpty) {
      return Image.asset("assets/logo/user.png", fit: BoxFit.cover);
    }

    if (_userProfile.imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: _userProfile.imagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            Image.asset("assets/logo/user.png", fit: BoxFit.cover),
      );
    } else {
      return Image.file(
        File(_userProfile.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset("assets/logo/user.png", fit: BoxFit.cover),
      );
    }
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
                      child: ClipOval(child: _buildProfileImage()),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
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
                onTap: _showEditNameDialog,
                child: ProfileInfoCard(
                  icon: Icons.person_2_outlined,
                  label: 'Name',
                  value: _userProfile.name,
                  editable: true,
                ),
              ),
              const SizedBox(height: 20.0),
              ProfileInfoCard(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _userProfile.email,
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: _logout,
                child: ProfileActionCard(
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  textStyle: AppWidget.semiboldTextFieldStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}