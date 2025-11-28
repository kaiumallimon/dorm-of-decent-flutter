import 'dart:convert';
import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _keyUserData = 'user_data';

  /// Save user data to local storage
  static Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(userData.toJson());
    await prefs.setString(_keyUserData, userJson);
  }

  /// Get user data from local storage
  static Future<UserData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUserData);

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserData.fromJson(userMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear user data from local storage
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
  }

  /// Check if user data exists
  static Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserData);
  }
}
