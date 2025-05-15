import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "userId";
  static const String userNameKey = "userName";
  static const String userEmailKey = "userEmail";
  static const String userPasswordKey = "userPassword";
  static const String userImageKey = "userImage";
  static const String cartProductsKey = "cartProducts";

  static final SharedPreferenceHelper _instance = SharedPreferenceHelper._internal();
  factory SharedPreferenceHelper() => _instance;
  SharedPreferenceHelper._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<bool> saveUserId(String userId) async {
    final prefs = await _prefs;
    return prefs.setString(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey);
  }

  Future<bool> saveUserName(String userName) async {
    final prefs = await _prefs;
    return prefs.setString(userNameKey, userName);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(userNameKey);
  }

  Future<bool> saveUserEmail(String userEmail) async {
    final prefs = await _prefs;
    return prefs.setString(userEmailKey, userEmail);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(userEmailKey);
  }

  Future<bool> saveUserPassword(String userPassword) async {
    final prefs = await _prefs;
    return prefs.setString(userPasswordKey, userPassword);
  }

  Future<String?> getUserPassword() async {
    final prefs = await _prefs;
    return prefs.getString(userPasswordKey);
  }

  Future<bool> saveUserImage(String userImage) async {
    final prefs = await _prefs;
    return prefs.setString(userImageKey, userImage);
  }

  Future<String?> getUserImage() async {
    final prefs = await _prefs;
    return prefs.getString(userImageKey);
  }

 
  Future<bool> clearUserData() async {
    final prefs = await _prefs;
    return Future.wait([
      prefs.remove(userIdKey),
      prefs.remove(userPasswordKey),
      
    ]).then((results) => results.every((result) => result));
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(userIdKey) != null;
  }
}
