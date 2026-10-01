import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'dart:convert';

/// Storage Service for handling local data persistence
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  late SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();
  bool _initialized = false;
  
  StorageService._internal();
  
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }
  
  // Secure Storage (for tokens)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.keyAccessToken,
      value: token,
    );
  }
  
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAccessToken);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: token,
    );
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }
  
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }
  
  // SharedPreferences (for non-sensitive data)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(
      AppConstants.keyUserData,
      jsonEncode(userData),
    );
  }
  
  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(AppConstants.keyUserData);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }
  
  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.keyUserRole, role);
  }
  
  String? getUserRole() {
    return _prefs.getString(AppConstants.keyUserRole);
  }
  
  Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs.setBool(AppConstants.keyIsFirstTime, isFirstTime);
  }
  
  bool isFirstTime() {
    return _prefs.getBool(AppConstants.keyIsFirstTime) ?? true;
  }
  
  // Generic methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }
  
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  Future<void> clear() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
  
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
