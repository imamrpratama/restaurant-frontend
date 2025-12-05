import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management (Secure Storage)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // User Data (Shared Preferences)
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setInt('user_id', user['id']);
    await _prefs?.setString('user_name', user['name']);
    await _prefs?.setString('user_email', user['email']);
    await _prefs?.setBool(
        'two_factor_enabled', user['two_factor_enabled'] ?? false);
  }

  Map<String, dynamic>? getUser() {
    final id = _prefs?.getInt('user_id');
    if (id == null) return null;

    return {
      'id': id,
      'name': _prefs?.getString('user_name'),
      'email': _prefs?.getString('user_email'),
      'two_factor_enabled': _prefs?.getBool('two_factor_enabled') ?? false,
    };
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
