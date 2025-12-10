import 'package:flutter/material.dart';
import '../../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores base para los iconos
    final Color iconColor = isDark ? Colors.blueAccent.shade100 : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Configuración", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // CABECERA
          Text(
            "Preferencias",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 15),

          // -------------------------------------------
          // GRUPO 1: EXPERIENCIA (SONIDO / VIBRACIÓN)
          // -------------------------------------------
          _buildSettingsGroup(context, children: [
            _buildSwitchTile(
              context,
              icon: Icons.volume_up_rounded,
              title: "Efectos de Sonido",
              subtitle: "Clics y sonidos de victoria",
              value: appState.isSoundEnabled,
              activeColor: Colors.orange,
              onChanged: (val) {
                appState.setSound(val);
                if (val) appState.playClick();
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              context,
              icon: Icons.vibration_rounded,
              title: "Vibración Háptica",
              subtitle: "Sentir el sorteo en tus manos",
              value: appState.isHapticEnabled,
              activeColor: Colors.purple,
              onChanged: (val) {
                appState.setHaptic(val);
                if (val) appState.vibrateSuccess();
              },
            ),
          ]),

          const SizedBox(height: 30),
          Text(
            "Apariencia",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 15),

          // -------------------------------------------
          // GRUPO 2: TEMA (DARK MODE)
          // -------------------------------------------
          _buildSettingsGroup(context, children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.dark_mode_rounded, color: Colors.indigo),
              ),
              title: const Text("Modo Oscuro", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                _getThemeName(appState.themeMode),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              onTap: () => _showThemePicker(context),
            ),
          ]),

          const SizedBox(height: 30),
          Text(
            "Sistema",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 15),

          // -------------------------------------------
          // GRUPO 3: INFORMACIÓN
          // -------------------------------------------
          _buildSettingsGroup(context, children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.grey),
              ),
              title: const Text("Versión", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("v1.0.0", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Dulceyson Projects © 2025",
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.4), fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Color activeColor,
        required Function(bool) onChanged,
      }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: activeColor),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey.withValues(alpha: 0.1));
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return "Automático (Sistema)";
      case ThemeMode.light: return "Claro";
      case ThemeMode.dark: return "Oscuro";
    }
  }

  // Selector de Tema (Modal Inferior)
  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text("Selecciona un tema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildThemeOption(context, "Automático", ThemeMode.system, Icons.brightness_auto),
              _buildThemeOption(context, "Claro", ThemeMode.light, Icons.wb_sunny_rounded),
              _buildThemeOption(context, "Oscuro", ThemeMode.dark, Icons.dark_mode_rounded),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String text, ThemeMode mode, IconData icon) {
    final isSelected = appState.themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(text, style: TextStyle(color: isSelected ? Colors.blue : null, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        appState.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}