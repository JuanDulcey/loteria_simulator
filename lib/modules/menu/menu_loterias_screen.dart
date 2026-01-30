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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Configuración de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---------------------------------------------------------
          // 1. CABECERA PREMIUM (SliverAppBar)
          // ---------------------------------------------------------
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : colorScheme.primary,
            elevation: 0,

            // ACCIONES (PERFIL Y AJUSTES)
            actions: [
              IconButton(
                // Si está logueado, icono relleno. Si no, contorno.
                icon: Icon(
                  appState.isLoggedIn ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                ),
                tooltip: appState.isLoggedIn ? 'Mi Perfil' : 'Iniciar Sesión',
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
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: 'Configuración',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen(appState: appState)),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],

            // ESPACIO FLEXIBLE (Fondo con Gradiente y Diseño)
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'LOTERÍA SIMULATOR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo base
                  Container(color: const Color(0xFF0F172A)),

                  // Gradiente Decorativo
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A),
                          colorScheme.primary.withValues(alpha: 0.5),
                          const Color(0xFF1E293B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Icono gigante de fondo (Marca de agua)
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.casino_rounded,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Sombra inferior para que el texto se lea bien
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. LISTA DE LOTERÍAS
          // ---------------------------------------------------------
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // TÍTULO DE SECCIÓN
                Row(
                  children: [
                    Container(width: 4, height: 24, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(
                      "Sorteos Disponibles",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    "Selecciona tu juego favorito",
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
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

                // BOTÓN DE TUTORIAL
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
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET CONSTRUCTOR DE TARJETAS
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

    final borderRadius = BorderRadius.circular(24);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colorInicio.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            if (esActiva && destino != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => destino));
            } else {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.construction, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        "$nombre está en construcción",
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorInicio, colorFin],
              ),
            ),
            child: Container(
              // Si es destacada es más alta
              constraints: BoxConstraints(
                  minHeight: esDestacada ? 140 : 100
              ),
              child: Stack(
                children: [
                  // 1. Icono Gigante de Fondo (Decorativo)
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Icon(
                        icono,
                        size: esDestacada ? 160 : 120,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // 2. Contenido Principal
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Círculo del Icono
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Icon(icono, color: textColor, size: esDestacada ? 32 : 24),
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
                                  fontWeight: FontWeight.w900,
                                  fontSize: esDestacada ? 22 : 18,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitulo,
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.9),
                                  fontSize: esDestacada ? 13 : 11,
                                ),
                              ),

                              // Badge de "Próximamente" si no está activa
                              if (!esActiva) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "PRÓXIMAMENTE",
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),

                        // Flecha indicadora (solo si activa)
                        if (esActiva)
                          Icon(Icons.arrow_forward_ios_rounded, color: textColor.withValues(alpha: 0.6), size: 20),
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