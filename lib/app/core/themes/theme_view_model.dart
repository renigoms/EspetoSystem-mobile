import 'package:espetosystem/app/data/services/local_cache_service.dart';
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  final LocalCacheService _cacheService;
  static const String _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeViewModel(this._cacheService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  // O modal vai usar isso para saber qual bolinha marcar
  int themeIndex() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.system:
        return 2;
    }
  }

  void _loadTheme() {
    final savedTheme = _cacheService.get(_themeKey);
    if (savedTheme != null && savedTheme is String) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.light,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _cacheService.save(_themeKey, mode.name);
    notifyListeners();
  }
}
