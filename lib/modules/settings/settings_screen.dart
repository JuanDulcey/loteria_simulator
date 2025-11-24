import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, "Apariencia"),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text("Tema"),
            subtitle: Text(_getThemeName(appState.themeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: appState.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text("Sistema")),
                DropdownMenuItem(value: ThemeMode.light, child: Text("Claro")),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Oscuro")),
              ],
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  appState.setThemeMode(newValue);
                }
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, "Experiencia"),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text("Efectos de Sonido"),
            subtitle: const Text("Sonidos al hacer click y generar números"),
            value: appState.isSoundEnabled,
            onChanged: (bool value) {
              appState.setSound(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text("Vibración"),
            subtitle: const Text("Feedback háptico al interactuar"),
            value: appState.isHapticEnabled,
            onChanged: (bool value) {
              appState.setHaptic(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Ver Tutorial"),
            subtitle: const Text("Reiniciar el tour de bienvenida"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OnboardingScreen(appState: appState))
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return "Claro";
      case ThemeMode.dark: return "Oscuro";
      case ThemeMode.system: return "Automático (Sistema)";
    }
  }
}
