import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'settings_service.dart';
import 'auth_service.dart';
import 'history_service.dart'; // 1. IMPORTANTE: Importar HistoryService
import '../modules/auth/models/user_model.dart';

class AppState extends ChangeNotifier {
  final SettingsService _settingsService;
  late final AuthService _authService;
  // 2. Instanciamos el servicio de historial
  final HistoryService _historyService = HistoryService();

  late ThemeMode _themeMode;
  late bool _isSoundEnabled;
  late bool _isHapticEnabled;
  late bool _hasSeenOnboarding;

  UserModel? _currentUser;
  bool _isAuthLoading = false;
  bool _isGuestMode = false;

  AppState(this._settingsService) {
    _themeMode = _settingsService.themeMode;
    _isSoundEnabled = _settingsService.isSoundEnabled;
    _isHapticEnabled = _settingsService.isHapticEnabled;
    _hasSeenOnboarding = _settingsService.hasSeenOnboarding;

    _authService = AuthService(_settingsService.prefs);
    _currentUser = _authService.getCurrentUser();

    // 3. SINCRONIZACIÓN AL INICIAR APP
    // Si la app se abre y ya hay una sesión guardada, sincronizamos en segundo plano
    if (_currentUser != null) {
      _historyService.sincronizarDesdeNube().then((_) => notifyListeners());
    }
  }

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isHapticEnabled => _isHapticEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuestMode => _isGuestMode;
  bool get isAuthLoading => _isAuthLoading;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
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

  void enableGuestMode() {
    _isGuestMode = true;
    notifyListeners();
  }

  // --- Auth Actions con Sync ---

  Future<void> login() async {
    if (_isAuthLoading) return;
    _isAuthLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _isGuestMode = false; // Ya no es invitado

        // 4. MAGIA AQUÍ: Sincronizar historial al loguearse
        await _historyService.sincronizarDesdeNube();

        await vibrateSuccess();
      }
    } catch (e) {
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
      // 1. Cerrar sesión en servicios
      await _authService.signOut();
      _currentUser = null;
      _isGuestMode = false;

      // 2. MAGIA AQUÍ: Limpiar historial local para proteger privacidad
      await _historyService.limpiarHistorial();

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
    if (_isSoundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> vibrate() async {
    if (_isHapticEnabled) await HapticFeedback.lightImpact();
  }

  Future<void> vibrateSuccess() async {
    if (_isHapticEnabled) await HapticFeedback.mediumImpact();
  }
}