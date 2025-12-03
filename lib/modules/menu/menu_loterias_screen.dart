import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/app_state.dart';
import '../baloto/baloto_screen.dart';
import '../settings/settings_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/profile_screen.dart';

class MenuLoteriasScreen extends StatelessWidget {
  final AppState appState;

  const MenuLoteriasScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    // Update system UI overlay based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. CABECERA PREMIUM
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            actions: [
               IconButton(
                 icon: Icon(appState.isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined),
                 onPressed: () {
                   if (appState.isLoggedIn) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => ProfileScreen(appState: appState)),
                     );
                   } else {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => LoginScreen(appState: appState)),
                     );
                   }
                 },
               ),
               IconButton(
                 icon: const Icon(Icons.settings),
                 onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => SettingsScreen(appState: appState)),
                   );
                 },
               ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'COLOMBIA LOTTERY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Container(
                     color: const Color(0xFF0F172A), // Fallback background
                   ),
                   // Use a gradient or asset instead of network image to avoid loading issues in restricted envs
                   Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A),
                          const Color(0xFF1E293B),
                          colorScheme.primary.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                       child: Icon(Icons.casino, size: 100, color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8), // Always dark overlay for text visibility
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. LISTA DE LOTERÍAS
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  "Sorteos Disponibles",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Selecciona tu juego favorito para empezar a simular",
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 25),

                // --- TARJETA BALOTO (Destacada) ---
                _buildPremiumCard(
                  context,
                  nombre: "BALOTO",
                  subtitulo: "El acumulado multimillonario",
                  colorInicio: const Color(0xFF003366),
                  colorFin: const Color(0xFF00509E),
                  icono: Icons.star_rate_rounded,
                  esActiva: true,
                  esDestacada: true,
                  destino: BalotoScreen(appState: appState),
                ),

                const SizedBox(height: 20),

                // --- OTRAS LOTERÍAS ---
                _buildPremiumCard(
                  context,
                  nombre: "ANTIOQUEÑITA",
                  subtitulo: "La suerte paisa",
                  colorInicio: const Color(0xFF1B5E20),
                  colorFin: const Color(0xFF43A047),
                  icono: Icons.location_on_rounded,
                  esActiva: false,
                ),

                const SizedBox(height: 15),

                _buildPremiumCard(
                  context,
                  nombre: "CHONTICO",
                  subtitulo: "Millonario al instante",
                  colorInicio: const Color(0xFFE65100),
                  colorFin: const Color(0xFFFF9800),
                  icono: Icons.wb_sunny_rounded,
                  esActiva: false,
                ),

                const SizedBox(height: 15),

                _buildPremiumCard(
                  context,
                  nombre: "EL DORADO",
                  subtitulo: "Leyenda de oro",
                  colorInicio: const Color(0xFFB8860B),
                  colorFin: const Color(0xFFFFD700),
                  icono: Icons.auto_awesome_rounded,
                  esActiva: false,
                  textColor: Colors.black87,
                ),

                const SizedBox(height: 40),

                // Button to restart tutorial manually (Alternative to settings)
                Center(
                  child: TextButton.icon(
                    icon: Icon(Icons.help_outline, color: colorScheme.secondary),
                    label: Text("Ver Tutorial de Bienvenida", style: TextStyle(color: colorScheme.secondary)),
                    onPressed: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => OnboardingScreen(appState: appState)),
                         );
                    },
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
      BuildContext context, {
        required String nombre,
        required String subtitulo,
        required Color colorInicio,
        required Color colorFin,
        required IconData icono,
        required bool esActiva,
        bool esDestacada = false,
        Widget? destino,
        Color textColor = Colors.white,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorInicio.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (esActiva && destino != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => destino));
            } else {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "$nombre está en construcción 🚧",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: theme.cardColor,
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: (){},
                    textColor: theme.colorScheme.primary
                  ),
                ),
              );
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorInicio, colorFin],
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                  minHeight: esDestacada ? 140 : 100
              ),
              child: Stack(
                children: [
                  // Fondo decorativo
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      icono,
                      size: esDestacada ? 150 : 100,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono Principal
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Icon(icono, color: textColor, size: esDestacada ? 30 : 24),
                        ),
                        const SizedBox(width: 20),

                        // Textos
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nombre,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: esDestacada ? 24 : 18,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitulo,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: esDestacada ? 14 : 12,
                                ),
                              ),
                              if (!esActiva) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "PRÓXIMAMENTE",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),

                        // Flecha indicadora
                        if (esActiva)
                          Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.7), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
