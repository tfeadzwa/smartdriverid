import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final List<Map<String, String>> _users = [];
  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson);
      _users.clear();
      _users.addAll(
        decoded.cast<Map<String, dynamic>>().map(
          (e) => e.map((k, v) => MapEntry(k, v.toString())),
        ),
      );
    }
    _initialized = true;
  }

  static Future<bool> login(
    String identifier,
    String password,
    String role,
  ) async {
    await _init();
    return _users.any(
      (user) =>
          user['identifier'] == identifier &&
          user['password'] == password &&
          user['role'] == role,
    );
  }

  static Future<bool> register(
    String identifier,
    String password,
    String role,
  ) async {
    await _init();
    final exists = _users.any((user) => user['identifier'] == identifier);
    if (exists) {
      return false;
    }
    _users.add({'identifier': identifier, 'password': password, 'role': role});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', jsonEncode(_users));
    return true;
  }
}
