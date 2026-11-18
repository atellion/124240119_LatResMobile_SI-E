import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Semua akun hasil register disimpan sebagai JSON {username: password}
  static Future<Map<String, String>> _getUsers(SharedPreferences p) async {
    final raw = p.getString('users');
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  // false = username sudah dipakai
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers(prefs);
    if (users.containsKey(username)) return false;
    users[username] = password;
    await prefs.setString('users', jsonEncode(users));
    return true;
  }

  // Login hanya berhasil jika akun sudah diregister
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getUsers(prefs);
    if (users[username] != password || !users.containsKey(username)) {
      return false;
    }
    await prefs.setBool('loginData', true);
    await prefs.setString('username', username);
    return true;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loginData') ?? false;
  }

  static Future<String> currentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('username');
  }
}
