import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  // Keys as static constants (unchanged)
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userPasswordKey = "USERPASSWORDKEY";
  static const String userImageKey = "USERIMAGEKEY";

  // Singleton instance
  static final SharedPreferenceHelper _instance =
      SharedPreferenceHelper._internal();
  factory SharedPreferenceHelper() => _instance;
  SharedPreferenceHelper._internal();

  // Cached SharedPreferences instance
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // User ID operations
  Future<bool> saveUserId(String userId) async {
    final prefs = await _prefs;
    return prefs.setString(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey);
  }

  // User Name operations
  Future<bool> saveUserName(String userName) async {
    final prefs = await _prefs;
    return prefs.setString(userNameKey, userName);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(userNameKey);
  }

  // User Email operations
  Future<bool> saveUserEmail(String userEmail) async {
    final prefs = await _prefs;
    return prefs.setString(userEmailKey, userEmail);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(userEmailKey);
  }

  // User Password operations (consider security implications)
  Future<bool> saveUserPassword(String userPassword) async {
    final prefs = await _prefs;
    return prefs.setString(userPasswordKey, userPassword);
  }

  Future<String?> getUserPassword() async {
    final prefs = await _prefs;
    return prefs.getString(userPasswordKey);
  }

  // User Image operations
  Future<bool> saveUserImage(String userImage) async {
    final prefs = await _prefs;
    return prefs.setString(userImageKey, userImage);
  }

  Future<String?> getUserImage() async {
    final prefs = await _prefs;
    return prefs.getString(userImageKey);
  }

  // Clear all user data (logout functionality)
  Future<bool> clearUserData() async {
    final prefs = await _prefs;
    return await Future.wait([
      prefs.remove(userIdKey),
      prefs.remove(userNameKey),
      prefs.remove(userEmailKey),
      prefs.remove(userPasswordKey),
      prefs.remove(userImageKey),
    ]).then((results) => results.every((result) => result));
  }

  // Clear all shared preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey) != null;
  }
}
