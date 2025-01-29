import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Helper class untuk mengelola penyimpanan data persistensi
class StorageHelper {
  // Keys untuk SharedPreferences
  static const String _rateLimitKey = 'rate_limit_data';
  static const String _userSessionKey = 'user_session';
  static const String _appSettingsKey = 'app_settings';

  /// Rate Limit Data Operations
  static Future<void> saveRateLimitData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rateLimitKey, json.encode(data));
  }

  static Future<Map<String, dynamic>?> getRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_rateLimitKey);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  static Future<void> clearRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rateLimitKey);
  }

  /// Generic Storage Operations
  static Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      await prefs.setString(key, json.encode(value));
    }
  }

  static Future<T?> getData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Error Handling
  static Future<bool> tryOperation(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      print('Storage operation failed: $e');
      return false;
    }
  }

  /// Session Management
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // lib/utils/storage_helper.dart
// Tambahkan method berikut:

  /// User Session Operations
  static Future<void> saveUserSession(Map<String, dynamic> sessionData) async {
    await saveData(_userSessionKey, sessionData);
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final data = await getData<String>(_userSessionKey);
    return data != null ? json.decode(data) : null;
  }

  static Future<void> clearUserSession() async {
    await removeData(_userSessionKey);
  }

  /// App Settings Operations
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveData(_appSettingsKey, settings);
  }

  static Future<Map<String, dynamic>?> getAppSettings() async {
    final data = await getData<String>(_appSettingsKey);
    return data != null ? json.decode(data) : null;
  }

  static Future<void> updateAppSettings(
      Map<String, dynamic> newSettings) async {
    final current = await getAppSettings() ?? {};
    current.addAll(newSettings);
    await saveAppSettings(current);
  }
}
