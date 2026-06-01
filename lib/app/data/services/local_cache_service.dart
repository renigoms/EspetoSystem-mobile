import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:espetosystem/app/data/services/base_data_source.dart';

class LocalCacheService implements IBaseLocalDataSource {
  final SharedPreferences prefs;

  LocalCacheService(this.prefs);

  @override
  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, json.encode(value));
    }
  }

  @override
  dynamic get(String key) {
    final data = prefs.get(key);
    if (data == null) return null;
    if (data is String) {
      try {
        return json.decode(data);
      } catch (e) {
        return data;
      }
    }
    return data;
  }

  @override
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await prefs.clear();
  }
}
