import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacena respuestas GET en SharedPreferences con TTL configurable.
/// La clave de caché es el path del endpoint (ej: "/usuario/data-home?idChofer=1").
class CacheService {
  static const int _cacheTtlHours = 10;

  static String _key(String path) => 'cache_$path';

  static Future<void> save(String path, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = {
      'data': data,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_key(path), json.encode(entry));
  }

  static Future<Map<String, dynamic>?> get(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(path));
    if (raw == null) return null;

    final entry = json.decode(raw) as Map<String, dynamic>;
    final savedAt = DateTime.parse(entry['savedAt'] as String);

    if (DateTime.now().difference(savedAt).inHours >= _cacheTtlHours) {
      await prefs.remove(_key(path));
      return null;
    }

    return entry['data'] as Map<String, dynamic>;
  }

  static Future<DateTime?> savedAt(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(path));
    if (raw == null) return null;
    final entry = json.decode(raw) as Map<String, dynamic>;
    return DateTime.parse(entry['savedAt'] as String);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
