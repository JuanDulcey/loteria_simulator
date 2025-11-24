import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';
import 'auth_service.dart';
import '../modules/auth/models/user_model.dart';

class AppState extends ChangeNotifier {
  final SettingsService _settingsService;
  late final AuthService _authService; // Initialize later or now?

  late ThemeMode _themeMode;
  late bool _isSoundEnabled;
  late bool _isHapticEnabled;
  late bool _hasSeenOnboarding;

  UserModel? _currentUser;
  bool _isAuthLoading = false;

  AppState(this._settingsService) {
    _themeMode = _settingsService.themeMode;
    _isSoundEnabled = _settingsService.isSoundEnabled;
    _isHapticEnabled = _settingsService.isHapticEnabled;
    _hasSeenOnboarding = _settingsService.hasSeenOnboarding;

    // Initialize AuthService using the same prefs from SettingsService
    _authService = AuthService(_settingsService.prefs);
    _currentUser = _authService.getCurrentUser();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticEnabled => _isHapticEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAuthLoading => _isAuthLoading;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
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

  // --- Auth Actions ---

  Future<void> login() async {
    if (_isAuthLoading) return;
    _isAuthLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      // Haptic feedback on success
      vibrateSuccess();
    } catch (e) {
      // Handle error
      debugPrint('Login failed: $e');
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isAuthLoading) return;
    _isAuthLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
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
