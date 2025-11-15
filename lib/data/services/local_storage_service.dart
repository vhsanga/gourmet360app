import 'package:Gourmet360/core/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _userKey = 'usuario_data';

  static Future<void> saveUser(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = usuario.toJson();
    await prefs.setString(_userKey, json.encode(userJson));
  }

  static Future<Usuario?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userKey);

    if (userJsonString != null) {
      final userJson = json.decode(userJsonString);
      return Usuario.fromJsonLocal(userJson);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }
}
