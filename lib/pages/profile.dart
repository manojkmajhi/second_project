import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/database/database.dart';
import 'package:second_project/database/shared_preferences.dart';
import 'package:second_project/pages/signin.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String? userImagePath;
  String? currentUserId;
  final SharedPreferenceHelper _sharedPrefsHelper = SharedPreferenceHelper();
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null && user.uid != currentUserId) {
        _fetchUserData();
      } else if (user == null && currentUserId != null) {
        _resetProfileData();
      } else if (user != null && user.uid == currentUserId) {
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
      userName = 'Guest';
      userEmail = 'Not logged in';
      userImagePath = null;
      currentUserId = null;
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fetchedName = user.displayName ?? 'Update name';
      String fetchedEmail = user.email ?? 'No email';
      String? fetchedImagePath;

      // 1. First check local file system
      fetchedImagePath = await LocalImageStorage.getLocalImagePath(user.uid);

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
            if (localUser['image'] != null &&
                localUser['image'].toString().isNotEmpty) {
              fetchedImagePath = localUser['image'].toString();
            }
            fetchedName = localUser['name']?.toString() ?? fetchedName;
          }
        }
      }

      // Update UI with initial values
      if (mounted) {
        setState(() {
          currentUserId = user.uid;
          userName = fetchedName;
          userEmail = fetchedEmail;
          userImagePath = fetchedImagePath;
        });
      }

      // 4. Check Firestore for most recent data (in background)
      try {
        final docSnapshot = await DatabaseMethods().getUserDetails(user.uid);
        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          final firestoreName = userData['name']?.toString();
          final firestoreImageUrl = userData['image']?.toString();

          // Only update if different from current values
          if (firestoreName != null && firestoreName != fetchedName) {
            fetchedName = firestoreName;
          }

          if (firestoreImageUrl != null &&
              firestoreImageUrl != fetchedImagePath) {
            // Download and cache the image locally
            if (firestoreImageUrl.startsWith('http')) {
              final cachedPath = await _cacheNetworkImage(
                firestoreImageUrl,
                user.uid,
              );
              if (cachedPath != null) {
                fetchedImagePath = cachedPath;
              }
            } else {
              fetchedImagePath = firestoreImageUrl;
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
        }
      } catch (e) {
        debugPrint("Error fetching from Firestore: $e");
      }

      // Final UI update if values changed
      if (mounted &&
          (userName != fetchedName || userImagePath != fetchedImagePath)) {
        setState(() {
          userName = fetchedName;
          userImagePath = fetchedImagePath;
        });
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

  Future<void> updateUserImage(File imageFile) async {
    if (currentUserId == null) {
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

      // 1. First save locally
      final localImagePath = await LocalImageStorage.saveImageLocally(
        imageFile,
        currentUserId!,
      );

      // Update UI immediately with local image
      if (localImagePath != null && mounted) {
        setState(() {
          userImagePath = localImagePath;
        });
      }

      // 2. Upload to Firebase Storage (in background)
      final imageUrl = await DatabaseMethods().uploadImageAndGetUrl(
        imageFile,
        currentUserId!,
      );

      if (imageUrl != null) {
        // 3. Update Firestore
        await DatabaseMethods().updateUserDetails({
          'image': imageUrl,
        }, currentUserId!);

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

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      await updateUserImage(File(pickedFile.path));
    }
  }

  Future<void> updateUserName(String newName) async {
    if (currentUserId == null) return;

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      await DatabaseMethods().updateUserDetails({
        'name': newName,
      }, currentUserId!);

      final storedLocalUserId = await _sharedPrefsHelper.getUserId();
      if (storedLocalUserId != null && storedLocalUserId == currentUserId) {
        final db = await DBHelper.instance.getDB();
        await db.update(
          "users",
          {'name': newName},
          where: "id = ?",
          whereArgs: [int.parse(storedLocalUserId)],
        );
        await _sharedPrefsHelper.saveUserName(newName);
      }

      setState(() => userName = newName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      }
    } catch (e) {
      debugPrint("Error updating name: $e");
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
    if (currentUserId != null) {
      await LocalImageStorage.deleteLocalImage(currentUserId!);
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
    if (userImagePath == null || userImagePath!.isEmpty) {
      return Image.asset("assets/logo/user.png", fit: BoxFit.cover);
    }

    if (userImagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: userImagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget:
            (context, url, error) =>
                Image.asset("assets/logo/user.png", fit: BoxFit.cover),
      );
    } else {
      return Image.file(
        File(userImagePath!),
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
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

class LocalImageStorage {
  static Future<String?> saveImageLocally(File imageFile, String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/user_$userId.jpg';

      // Compress image before saving
      final compressedImage = await _compressImage(imageFile, imagePath);
      await compressedImage.copy(imagePath);
      return imagePath;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  static Future<String?> getLocalImagePath(String userId) async {
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

  static Future<void> deleteLocalImage(String userId) async {
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

  static Future<File> _compressImage(File file, String targetPath) async {
    // In a real app, you might want to use flutter_image_compress package
    // For simplicity, we're just returning the original file here
    return file;
  }
}
