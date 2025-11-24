import 'package:flutter/material.dart';
import '../../../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;

  const ProfileScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    if (user == null) return const SizedBox();

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              backgroundColor: colors.primaryContainer,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 40, color: colors.onPrimaryContainer),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                // Navigate to settings or handle here
              },
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de Juegos'),
              onTap: () {
                // Navigate to history
              },
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  await appState.playClick();
                  await appState.logout();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
