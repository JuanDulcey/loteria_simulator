import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../baloto/baloto_screen.dart';

class MenuLoteriasScreen extends StatelessWidget {
  const MenuLoteriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. CABECERA PREMIUM
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
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
                  Image.network(
                    'https://images.unsplash.com/photo-1518688248740-759786498362?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF334155)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.casino, size: 80, color: Colors.white10),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0F172A).withOpacity(0.8),
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
                const Text(
                  "Sorteos Disponibles",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Selecciona tu juego favorito para empezar a simular",
                  style: TextStyle(color: Colors.grey),
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
                  destino: const BalotoScreen(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$nombre está en construcción 🚧"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1E293B),
                ),
              );
            }
          },
          child: Ink(
            // CORRECCIÓN 1: Eliminamos 'height' fijo.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorInicio, colorFin],
              ),
            ),
            // CORRECCIÓN 2: Usamos Container con constraints para permitir expansión
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
                      crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical centrada
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
                            // CORRECCIÓN 3: MainAxisSize.min para que no ocupe espacio innecesario
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