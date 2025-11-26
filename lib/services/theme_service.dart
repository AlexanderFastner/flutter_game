import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeIds {
  static const String neonRainGlitch = 'neon_rain_glitch';
  static const String neoTokyoSkyline = 'neo_tokyo_skyline';
}

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _storageKey = 'neon_escape_theme';

  Future<String> getCurrentThemeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_storageKey) ?? AppThemeIds.neoTokyoSkyline;
    } on MissingPluginException {
      return AppThemeIds.neoTokyoSkyline;
    }
  }

  Future<void> setCurrentThemeId(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, themeId);
    } on MissingPluginException {
      return;
    }
  }
}


