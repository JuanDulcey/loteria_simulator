import 'package:flutter/material.dart';
import '../../../services/app_state.dart';

class LoginScreen extends StatelessWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // ExtendBodyBehindAppBar permite que el gradiente suba hasta la barra de estado
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Usamos leadingWidth para evitar que el botón quede muy pegado
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F172A), // Azul noche oscuro (Premium)
              const Color(0xFF1E293B),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Evita overflow en pantallas pequeñas
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado o Icono
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.casino_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Bienvenido',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Inicia sesión para sincronizar tus simulaciones y acceder al historial avanzado.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),

                if (appState.isAuthLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Column(
                    children: [
                      _GoogleSignInButton(
                        onPressed: () async {
                          // 1. Sonido o feedback háptico (si tienes el método)
                          // await appState.playClick();

                          // 2. Ejecutar Login
                          await appState.login();

                          // 3. Cerrar pantalla si fue exitoso
                          if (appState.isLoggedIn && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Continuar como invitado',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de Google (simulado o imagen real)
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto', // Fuente estándar de Google
              ),
            ),
          ],
        ),
      ),
    );
  }
}