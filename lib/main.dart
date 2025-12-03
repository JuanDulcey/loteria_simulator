import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'modules/menu/menu_loterias_screen.dart';
import 'modules/onboarding/onboarding_screen.dart';
import 'modules/auth/screens/login_screen.dart';
import 'services/settings_service.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A. INICIALIZAR FIREBASE (Sin esto, AuthService falla)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("⚠️ Advertencia: No se pudo inicializar Firebase. Verifique configuración: $e");
  }

  // B. Bloquear rotación (Opcional, se ve mejor en vertical)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsService = await SettingsService.init();
  final appState = AppState(settingsService);

  runApp(LoteriaSimulatorApp(appState: appState));
}

class LoteriaSimulatorApp extends StatelessWidget {
  final AppState appState;

  const LoteriaSimulatorApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Lotería Simulator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,

          // C. LÓGICA DE NAVEGACIÓN ACTUALIZADA
          home: _getHomeScreen(),
        );
      },
    );
  }

  /// Decide qué pantalla mostrar basándose en el estado
  Widget _getHomeScreen() {
    // 1. Si no ha visto el tutorial -> Onboarding
    if (!appState.hasSeenOnboarding) {
      return OnboardingScreen(appState: appState);
    }

    // 2. Si ya vio tutorial pero NO está logueado y NO es invitado -> Login
    if (!appState.isLoggedIn && !appState.isGuestMode) {
      return LoginScreen(appState: appState);
    }

    // 3. Si todo está listo -> Menú Principal
    return MenuLoteriasScreen(appState: appState);
  }
}