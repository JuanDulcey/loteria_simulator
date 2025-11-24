import 'package:flutter/material.dart';
// Importamos los widgets y pantallas necesarias
import '../../widgets/balota_widget.dart';
import '../ambiente1/ambiente1_screen.dart';
import '../superbalota/super_balota_screen.dart';
import 'baloto_dashboard_screen.dart';
import '../../services/history_service.dart';
import 'historial_screen.dart';

class BalotoScreen extends StatefulWidget {
  const BalotoScreen({super.key});

  @override
  State<BalotoScreen> createState() => _BalotoScreenState();
}

class _BalotoScreenState extends State<BalotoScreen> {
  // Estado del ticket: 5 espacios vacíos inicialmente
  final List<int?> _misNumeros = [null, null, null, null, null];
  int? _superBalota;

  /// Método para navegar a un ambiente y esperar el número generado
  Future<void> _irAAmbiente(int indexArray, Widget pantalla) async {
    final int? numeroGenerado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );

    // Si regresó con un número, actualizamos el estado
    if (numeroGenerado != null) {
      setState(() {
        _misNumeros[indexArray] = numeroGenerado;
      });
    }
  }

  /// Reinicia todo el tablero
  void _resetearTodo() {
    setState(() {
      for (int i = 0; i < 5; i++) _misNumeros[i] = null;
      _superBalota = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos qué números ya existen para no repetirlos
    final numerosExistentes = _misNumeros.whereType<int>().toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'SIMULADOR BALOTO',
          style: TextStyle(letterSpacing: 1.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Estadísticas Masivas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BalotoDashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetearTodo,
            tooltip: 'Nuevo Sorteo',
          ),
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Ver Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistorialScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ---------------------------------------------
          // ZONA SUPERIOR: EL TICKET DE RESULTADOS
          // ---------------------------------------------
          Stack(
            children: [
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBE6), // Color papel
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TU APUESTA",
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Icon(Icons.qr_code_2, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Balotas Normales (1-5)
                          ...List.generate(5, (index) {
                            final numero = _misNumeros[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: numero == null
                                  ? _buildEmptySlot(index + 1)
                                  : BalotaWidget(numero: numero, size: 42),
                            );
                          }),

                          // Divisor visual
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),

                          // Superbalota
                          _superBalota == null
                              ? _buildEmptySlot(0, esSuper: true)
                              : BalotaWidget(
                            numero: _superBalota!,
                            size: 42,
                            esSuperBalota: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Decoración de línea punteada simulada
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          15,
                              (index) => Container(
                            width: 8,
                            height: 2,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ---------------------------------------------
          // ZONA INFERIOR: LOS MÓDULOS (GRID)
          // ---------------------------------------------
          Expanded(
            child: GridView.count(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                // AMBIENTE 1
                _buildModuleCard(
                  titulo: "AMBIENTE 1",
                  subtitulo: "Aleatorio Puro",
                  icon: Icons.shuffle_rounded,
                  colorBase: Colors.blueAccent,
                  activo: _misNumeros[0] == null,
                  bloqueado: false,
                  onTap: () => _irAAmbiente(
                      0, Ambiente1Screen(numerosExcluidos: numerosExistentes)),
                ),

                // AMBIENTE 2
                _buildModuleCard(
                  titulo: "AMBIENTE 2",
                  subtitulo: "Estadístico",
                  icon: Icons.bar_chart_rounded,
                  colorBase: Colors.purpleAccent,
                  activo: _misNumeros[1] == null,
                  bloqueado: _misNumeros[0] == null,
                  onTap: () => _irAAmbiente(
                      1, Ambiente1Screen(numerosExcluidos: numerosExistentes)),
                ),

                // AMBIENTE 3
                _buildModuleCard(
                  titulo: "AMBIENTE 3",
                  subtitulo: "Patrones",
                  icon: Icons.grid_on_rounded,
                  colorBase: Colors.orangeAccent,
                  activo: _misNumeros[2] == null,
                  bloqueado: _misNumeros[1] == null,
                  onTap: () => _irAAmbiente(
                      2, Ambiente1Screen(numerosExcluidos: numerosExistentes)),
                ),

                // AMBIENTE 4
                _buildModuleCard(
                  titulo: "AMBIENTE 4",
                  subtitulo: "Histórico",
                  icon: Icons.history_rounded,
                  colorBase: Colors.tealAccent,
                  activo: _misNumeros[3] == null,
                  bloqueado: _misNumeros[2] == null,
                  onTap: () => _irAAmbiente(
                      3, Ambiente1Screen(numerosExcluidos: numerosExistentes)),
                ),

                // AMBIENTE 5
                _buildModuleCard(
                  titulo: "AMBIENTE 5",
                  subtitulo: "Numerología",
                  icon: Icons.auto_awesome_rounded,
                  colorBase: Colors.pinkAccent,
                  activo: _misNumeros[4] == null,
                  bloqueado: _misNumeros[3] == null,
                  onTap: () => _irAAmbiente(
                      4, Ambiente1Screen(numerosExcluidos: numerosExistentes)),
                ),

                // SUPERBALOTA
                _buildModuleCard(
                  titulo: "SUPERBALOTA",
                  subtitulo: "El remate",
                  icon: Icons.star_rounded,
                  colorBase: Colors.redAccent,
                  esSuper: true,
                  activo: _superBalota == null,
                  bloqueado: _misNumeros.contains(null),
                  onTap: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuperBalotaScreen()),
                    );
                    if (resultado != null) {
                      setState(() {
                        _superBalota = resultado;
                      });
                      if (!_misNumeros.contains(null) && _superBalota != null) {
                        final numerosLimpios =
                        _misNumeros.whereType<int>().toList();
                        HistoryService().guardarJugada(
                            numeros: numerosLimpios,
                            superBalota: _superBalota!);

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("¡Ticket guardado exitosamente!"),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildModuleCard({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required Color colorBase,
    required bool activo,
    required bool bloqueado,
    required VoidCallback onTap,
    bool esSuper = false,
  }) {
    // Estado completado: No está activo (ya se jugó) y no está bloqueado
    bool completado = !activo && !bloqueado;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: bloqueado
            ? []
            : [
          BoxShadow(
            color: colorBase.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (bloqueado || completado) ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: bloqueado
                  ? LinearGradient(
                colors: [Colors.grey[200]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: completado
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: bloqueado
                  ? null
                  : Border.all(
                  color: completado
                      ? Colors.transparent
                      : colorBase.withOpacity(0.3),
                  width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  // Icono de fondo decorativo
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Icon(
                      icon,
                      size: 60,
                      color: completado
                          ? Colors.white.withOpacity(0.2)
                          : colorBase.withOpacity(0.1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header con Icono
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: completado
                              ? Colors.white.withOpacity(0.2)
                              : colorBase.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          completado ? Icons.check : icon,
                          color: completado ? Colors.white : colorBase,
                          size: 20,
                        ),
                      ),
                      // Textos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: completado
                                  ? Colors.white
                                  : (bloqueado
                                  ? Colors.grey
                                  : const Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            subtitulo,
                            style: TextStyle(
                              fontSize: 10,
                              color: completado
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int numero, {bool esSuper = false}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Center(
        child: Text(
          esSuper ? 'S' : '$numero',
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
