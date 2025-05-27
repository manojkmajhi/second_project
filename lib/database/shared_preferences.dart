// lib/database/shared_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  // Keys used in SharedPreferences
  static const String userIdKey = "userId";
  static const String userNameKey = "userName";
  static const String userEmailKey = "userEmail";
  static const String userImageKey = "userImage";
  static const String cartProductsKey = "cart_products";

  // New keys for 'Remember Me' functionality
  static const String rememberMeEmailKey = "rememberMeEmail";
  static const String rememberMeCheckboxStateKey = "rememberMeCheckboxState";

  // Singleton instance
  static final SharedPreferenceHelper _instance =
      SharedPreferenceHelper._internal();
  factory SharedPreferenceHelper() => _instance;
  SharedPreferenceHelper._internal();

  // Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Save/Get User ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await _prefs;
    return prefs.setString(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey);
  }

  // Save/Get User Name
  Future<bool> saveUserName(String userName) async {
    final prefs = await _prefs;
    return prefs.setString(userNameKey, userName);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(userNameKey);
  }

  // Save/Get User Email
  Future<bool> saveUserEmail(String userEmail) async {
    final prefs = await _prefs;
    return prefs.setString(userEmailKey, userEmail);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(userEmailKey);
  }

  // Save/Get User Image
  Future<bool> saveUserImage(String userImage) async {
    final prefs = await _prefs;
    return prefs.setString(userImageKey, userImage);
  }

  Future<String?> getUserImage() async {
    final prefs = await _prefs;
    return prefs.getString(userImageKey);
  }

  // --- New methods for 'Remember Me' functionality ---
  Future<bool> saveRememberMeEmail(String email) async {
    final prefs = await _prefs;
    return prefs.setString(rememberMeEmailKey, email);
  }

  Future<String?> getRememberMeEmail() async {
    final prefs = await _prefs;
    return prefs.getString(rememberMeEmailKey);
  }

  Future<bool> saveRememberMeCheckboxState(bool value) async {
    final prefs = await _prefs;
    return prefs.setBool(rememberMeCheckboxStateKey, value);
  }

  Future<bool> getRememberMeCheckboxState() async {
    final prefs = await _prefs;
    return prefs.getBool(rememberMeCheckboxStateKey) ?? false;
  }
  // --- End of 'Remember Me' methods ---


  // Remove only cart products
  Future<bool> removeCartProducts() async {
    final prefs = await _prefs;
    return prefs.remove(cartProductsKey);
  }

  // Clear all user-related data (for logout)
  Future<bool> clearUserData() async {
    final prefs = await _prefs;
    return Future.wait([
      prefs.remove(userIdKey),
      prefs.remove(userNameKey),
      prefs.remove(userEmailKey),
      prefs.remove(userImageKey),
      prefs.remove(cartProductsKey),
    ]).then((results) => results.every((result) => result));
  }

  // Clear 'Remember Me' specific data
  Future<void> clearRememberMeData() async {
    final prefs = await _prefs;
    await prefs.remove(rememberMeEmailKey);
    await prefs.remove(rememberMeCheckboxStateKey);
  }

  // Clear entire SharedPreferences (used in edge cases)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if a user is logged in by checking if userId exists
  Future<bool> isUserLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey) != null;
  }
}