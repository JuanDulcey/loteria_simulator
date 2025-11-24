import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyTheme = 'theme_mode'; // 'light', 'dark', 'system'
  static const String _keySound = 'sound_enabled';
  static const String _keyHaptic = 'haptic_enabled';
  static const String _keyOnboarding = 'onboarding_seen';

  final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  ThemeMode get themeMode {
    final mode = _prefs.getString(_keyTheme) ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
        break;
    }
    await _prefs.setString(_keyTheme, value);
  }

  bool get isSoundEnabled => _prefs.getBool(_keySound) ?? true;

  Future<void> updateSound(bool enabled) async {
    await _prefs.setBool(_keySound, enabled);
  }

  bool get isHapticEnabled => _prefs.getBool(_keyHaptic) ?? true;

  Future<void> updateHaptic(bool enabled) async {
    await _prefs.setBool(_keyHaptic, enabled);
  }

  bool get hasSeenOnboarding => _prefs.getBool(_keyOnboarding) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyOnboarding, true);
  }

  // Method to reset onboarding for testing purposes
  Future<void> resetOnboarding() async {
    await _prefs.remove(_keyOnboarding);
  }
}
