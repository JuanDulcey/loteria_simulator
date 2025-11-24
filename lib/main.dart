import 'package:flutter/material.dart';
import 'modules/menu/menu_loterias_screen.dart';
import 'modules/onboarding/onboarding_screen.dart';
import 'services/settings_service.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          home: appState.hasSeenOnboarding
              ? MenuLoteriasScreen(appState: appState)
              : OnboardingScreen(appState: appState),
        );
      },
    );
  }
}
