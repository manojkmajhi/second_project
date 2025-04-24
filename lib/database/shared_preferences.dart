import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userPasswordKey = "USERPASSWORDKEY";
  static const String userImageKey = "USERIMAGEKEY";
  static const String cartProductsKey = "cart_products"; // ✅ added

  static final SharedPreferenceHelper _instance =
      SharedPreferenceHelper._internal();
  factory SharedPreferenceHelper() => _instance;
  SharedPreferenceHelper._internal();

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

  // Save/Get Email
  Future<bool> saveUserEmail(String userEmail) async {
    final prefs = await _prefs;
    return prefs.setString(userEmailKey, userEmail);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(userEmailKey);
  }

  // Save/Get Password
  Future<bool> saveUserPassword(String userPassword) async {
    final prefs = await _prefs;
    return prefs.setString(userPasswordKey, userPassword);
  }

  Future<String?> getUserPassword() async {
    final prefs = await _prefs;
    return prefs.getString(userPasswordKey);
  }

  // Save/Get Image
  Future<bool> saveUserImage(String userImage) async {
    final prefs = await _prefs;
    return prefs.setString(userImageKey, userImage);
  }

  Future<String?> getUserImage() async {
    final prefs = await _prefs;
    return prefs.getString(userImageKey);
  }

  // ✅ Remove Cart Products
  Future<bool> removeCartProducts() async {
    final prefs = await _prefs;
    return prefs.remove(cartProductsKey);
  }

  // ✅ Clear all user data + cart products (for logout)
  Future<bool> clearUserData() async {
    final prefs = await _prefs;
    return Future.wait([
      prefs.remove(userIdKey),
      prefs.remove(userNameKey),
      prefs.remove(userEmailKey),
      prefs.remove(userPasswordKey),
      prefs.remove(userImageKey),
      prefs.remove(cartProductsKey), // ✅ clear cart too
    ]).then((results) => results.every((result) => result));
  }

  // Clear all shared preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check login
  Future<bool> isUserLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey) != null;
  }
}
