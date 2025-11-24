import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'settings_service.dart';
import 'auth_service.dart';
import '../modules/auth/models/user_model.dart';

class AppState extends ChangeNotifier {
  final SettingsService _settingsService;
  late final AuthService _authService;

  late ThemeMode _themeMode;
  late bool _isSoundEnabled;
  late bool _isHapticEnabled;
  late bool _hasSeenOnboarding;

  UserModel? _currentUser;
  bool _isAuthLoading = false;

  AppState(this._settingsService) {
    // 1. Cargar preferencias guardadas
    _themeMode = _settingsService.themeMode;
    _isSoundEnabled = _settingsService.isSoundEnabled;
    _isHapticEnabled = _settingsService.isHapticEnabled;
    _hasSeenOnboarding = _settingsService.hasSeenOnboarding;

    // 2. Inicializar AuthService inyectando las preferencias
    // Esto conecta con el AuthService que arreglamos en el paso anterior
    _authService = AuthService(_settingsService.prefs);

    // 3. Cargar usuario si ya existía sesión guardada localmente
    _currentUser = _authService.getCurrentUser();
  }

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticEnabled => _isHapticEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAuthLoading => _isAuthLoading;

  /// CORRECCIÓN IMPORTANTE:
  /// Detecta si la app se ve oscura, incluso si está en modo "Automático/System"
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Preguntamos al sistema operativo cuál es el brillo actual
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // --- Setters / Actions ---

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _settingsService.updateThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    // Si es Dark (o Sistema Dark), pasamos a Light. De lo contrario a Dark.
    if (isDarkMode) {
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
      // Llamada al servicio real de Firebase/Google
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        await vibrateSuccess(); // Feedback táctil si es exitoso
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      // Aquí podrías agregar una variable de error para mostrar en la UI
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
      await vibrate();
    } catch (e) {
      debugPrint('Logout failed: $e');
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  // --- Feedback Actions ---

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