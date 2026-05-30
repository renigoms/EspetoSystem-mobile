import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  final SharedPreferences prefs;

  LocalCacheService(this.prefs);

  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is Map || value is List) {
      await prefs.setString(key, json.encode(value));
    }
  }

  dynamic get(String key) {
    final data = prefs.getString(key);
    if (data == null) return null;
    try {
      return json.decode(data);
    } catch (e) {
      return data;
    }
  }

  Future<void> remove(String key) async {
    await prefs.remove(key);
  }
}
