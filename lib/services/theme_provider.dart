import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 14.0;
  Locale _locale = const Locale('fr');

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  Locale get locale => _locale;

  ThemeProvider() {
    _loadFromPrefs();
  }

  // Charger les réglages au démarrage
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Thème
    final themeStr = prefs.getString('themeMode') ?? 'system';
    _themeMode = _getThemeModeFromString(themeStr);

    // Police
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;

    // Langue
    final langCode = prefs.getString('languageCode') ?? 'fr';
    _locale = Locale(langCode);

    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  void setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  ThemeMode _getThemeModeFromString(String themeStr) {
    switch (themeStr) {
      case 'dark': return ThemeMode.dark;
      case 'light': return ThemeMode.light;
      default: return ThemeMode.system;
    }
  }
}
