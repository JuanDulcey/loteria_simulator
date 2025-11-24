import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para el mock

// Importa tus archivos
import 'package:loteria_simulator/main.dart';
import 'package:loteria_simulator/services/app_state.dart';
import 'package:loteria_simulator/services/settings_service.dart';

void main() {
  testWidgets('La app carga correctamente con AppState', (WidgetTester tester) async {
    // 1. SIMULAR BASE DE DATOS LOCAL (SharedPreferences)
    // Esto es necesario porque SettingsService intenta leer el disco.
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': true, // Simulamos que ya vio el onboarding
      'themeMode': 'system',
    });

    // 2. INICIALIZAR SERVICIOS MANUALMENTE
    // Como estamos en un test, el "main" real no se ejecuta, así que lo hacemos aquí.
    final settingsService = await SettingsService.init();
    final appState = AppState(settingsService);

    // 3. CARGAR LA APP PASANDO EL ESTADO
    // Aquí es donde solucionamos el error "appState is required"
    await tester.pumpWidget(LoteriaSimulatorApp(appState: appState));

    // 4. ESPERAR Y VERIFICAR
    await tester.pumpAndSettle();

    // Verificamos que cargó el menú (porque hasSeenOnboarding es true)
    expect(find.text('COLOMBIA LOTTERY'), findsOneWidget);
    expect(find.text('Sorteos Disponibles'), findsOneWidget);
  });
}