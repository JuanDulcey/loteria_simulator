import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';

class AppState extends ChangeNotifier {
  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late bool _isSoundEnabled;
  late bool _isHapticEnabled;
  late bool _hasSeenOnboarding;

  AppState(this._settingsService) {
    _themeMode = _settingsService.themeMode;
    _isSoundEnabled = _settingsService.isSoundEnabled;
    _isHapticEnabled = _settingsService.isHapticEnabled;
    _hasSeenOnboarding = _settingsService.hasSeenOnboarding;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticEnabled => _isHapticEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Typically need context to know system brightness, but we can default to false or rely on UI
      // However, for logical checks, we might check platform brightness if available,
      // but simpler to just return false if system.
      // Or better, let the UI handle ThemeMode.system.
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _settingsService.updateThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setSound(bool enabled) async {
    if (enabled == _isSoundEnabled) return;
    _isSoundEnabled = enabled;
    notifyListeners();
    await _settingsService.updateSound(enabled);
  }

  Future<void> setHaptic(bool enabled) async {
    if (enabled == _isHapticEnabled) return;
    _isHapticEnabled = enabled;
    notifyListeners();
    await _settingsService.updateHaptic(enabled);
  }

  Future<void> completeOnboarding() async {
    if (_hasSeenOnboarding) return;
    _hasSeenOnboarding = true;
    notifyListeners();
    await _settingsService.completeOnboarding();
  }

  // --- Actions ---

  Future<void> playClick() async {
    if (_isSoundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> vibrate() async {
    if (_isHapticEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> vibrateSuccess() async {
    if (_isHapticEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }
}
