import 'package:flutter/material.dart';
// Importamos los widgets y pantallas necesarias
import '../../widgets/balota_widget.dart';
import 'screens/generador_balota_screen.dart'; // IMPORTANTE: Nueva pantalla genérica
import '../superbalota/super_balota_screen.dart';
import 'baloto_dashboard_screen.dart';
import '../../services/history_service.dart';
import '../../services/app_state.dart';
import 'historial_screen.dart';

class BalotoScreen extends StatefulWidget {
  final AppState? appState;

  const BalotoScreen({super.key, this.appState});

  @override
  State<BalotoScreen> createState() => _BalotoScreenState();
}

class _BalotoScreenState extends State<BalotoScreen> {
  // Estado del ticket: 5 espacios vacíos inicialmente
  final List<int?> _misNumeros = [null, null, null, null, null];
  int? _superBalota;

  /// Método para navegar a un ambiente y esperar el número generado
  Future<void> _irAAmbiente(int indexArray, Widget pantalla) async {
    widget.appState?.playClick();
    final int? numeroGenerado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );

    // Si regresó con un número, actualizamos el estado
    if (numeroGenerado != null) {
      setState(() {
        _misNumeros[indexArray] = numeroGenerado;
      });
      widget.appState?.vibrate();
    }
  }

  /// Reinicia todo el tablero
  void _resetearTodo() {
    widget.appState?.playClick();
    setState(() {
      for (int i = 0; i < 5; i++) {
        _misNumeros[i] = null;
      }
      _superBalota = null;
    });
    widget.appState?.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos qué números ya existen para no repetirlos
    final numerosExistentes = _misNumeros.whereType<int>().toList();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'SIMULADOR',
          style: TextStyle(letterSpacing: 1.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // AppBar uses theme color now
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Estadísticas Masivas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BalotoDashboardScreen()),
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
                MaterialPageRoute(
                    builder: (context) => const HistorialScreen()),
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
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor ?? const Color(0xFF0F172A),
                  borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                           ? theme.colorScheme.surface
                           : const Color(0xFFFFFBE6), // Paper color in light mode, surface in dark
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
                          Text(
                            "TU APUESTA",
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Icon(Icons.qr_code_2, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 15),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Balotas Normales (1-5)
                            ...List.generate(5, (index) {
                              final numero = _misNumeros[index];
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                                child: numero == null
                                    ? _buildEmptySlot(index + 1)
                                    : BalotaWidget(numero: numero, size: 42),
                              );
                            }),

                            // Divisor visual
                            Container(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                      0,
                      GeneradorBalotaScreen(
                        numerosExcluidos: numerosExistentes,
                        titulo: "Ambiente 1: Aleatorio",
                        tipo: TipoGeneracion.aleatorio,
                        colorTema: Colors.blueAccent,
                        appState: widget.appState,
                      )),
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
                      1,
                      GeneradorBalotaScreen(
                        numerosExcluidos: numerosExistentes,
                        titulo: "Ambiente 2: Estadístico",
                        tipo: TipoGeneracion.estadistico,
                        colorTema: Colors.purpleAccent,
                        appState: widget.appState,
                      )),
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
                      2,
                      GeneradorBalotaScreen(
                        numerosExcluidos: numerosExistentes,
                        titulo: "Ambiente 3: Patrones",
                        tipo: TipoGeneracion.patrones,
                        colorTema: Colors.orangeAccent,
                        appState: widget.appState,
                      )),
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
                      3,
                      GeneradorBalotaScreen(
                        numerosExcluidos: numerosExistentes,
                        titulo: "Ambiente 4: Histórico",
                        tipo: TipoGeneracion.historico,
                        colorTema: Colors.tealAccent,
                        appState: widget.appState,
                      )),
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
                      4,
                      GeneradorBalotaScreen(
                        numerosExcluidos: numerosExistentes,
                        titulo: "Ambiente 5: Numerología",
                        tipo: TipoGeneracion.numerologia,
                        colorTema: Colors.pinkAccent,
                        appState: widget.appState,
                      )),
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
                    widget.appState?.playClick();
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SuperBalotaScreen(appState: widget.appState)),
                    );
                    if (resultado != null) {
                      setState(() {
                        _superBalota = resultado;
                      });
                      widget.appState?.vibrateSuccess();

                      if (!_misNumeros.contains(null) && _superBalota != null) {
                        final numerosLimpios =
                        _misNumeros.whereType<int>().toList();
                        HistoryService().guardarJugada(
                            numeros: numerosLimpios,
                            superBalota: _superBalota!);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Text("¡Ticket guardado exitosamente!"),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: theme.colorScheme.primary,
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
    bool completado = !activo && !bloqueado;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adjust colors for dark mode
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final cardColorDisabled = isDark ? Colors.grey[800]! : Colors.grey[50]!;

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
                colors: isDark
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.grey[200]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: completado
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [cardColor, cardColorDisabled],
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
                                  : theme.textTheme.bodyLarge?.color),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
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
