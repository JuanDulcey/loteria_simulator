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
    // Esto crea una lista limpia solo con los números (quita los null)
    final numerosExistentes = _misNumeros.whereType<int>().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador Baloto'),
        backgroundColor: const Color(0xFF003366), // Azul Oscuro Institucional
        foregroundColor: Colors.white,
        actions: [
          // BOTÓN NUEVO: Ir al Dashboard
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
          // Botón Historial
          IconButton(
            icon: const Icon(Icons.history_edu), // Icono de historial elegante
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFF003366).withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Balotas Normales (1-5)
                ...List.generate(5, (index) {
                  final numero = _misNumeros[index];
                  if (numero == null) {
                    return _buildEmptySlot(index + 1);
                  }
                  return BalotaWidget(numero: numero, size: 45);
                }),

                // Divisor visual
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 2, height: 40, color: Colors.grey[300]
                ),

                // Superbalota
                _superBalota == null
                    ? _buildEmptySlot(0, esSuper: true)
                    : BalotaWidget(numero: _superBalota!, size: 45, esSuperBalota: true),
              ],
            ),
          ),

          const Divider(height: 1),

          // ---------------------------------------------
          // ZONA INFERIOR: LOS MÓDULOS (GRID)
          // ---------------------------------------------
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                // AMBIENTE 1
                _buildModuleCard(
                  titulo: "Ambiente 1",
                  subtitulo: "Aleatorio Puro",
                  icon: Icons.filter_1,
                  activo: _misNumeros[0] == null,
                  bloqueado: false,
                  onTap: () => _irAAmbiente(
                      0,
                      Ambiente1Screen(numerosExcluidos: numerosExistentes)
                  ),
                ),

                // AMBIENTE 2 (Solo se activa si el 1 ya se jugó)
                _buildModuleCard(
                  titulo: "Ambiente 2",
                  subtitulo: "Estadístico",
                  icon: Icons.filter_2,
                  activo: _misNumeros[1] == null,
                  bloqueado: _misNumeros[0] == null,
                  onTap: () => _irAAmbiente(
                      1,
                      // NOTA: Aquí usamos Ambiente1Screen temporalmente.
                      // Cuando crees Ambiente2Screen, cámbialo aquí.
                      Ambiente1Screen(numerosExcluidos: numerosExistentes)
                  ),
                ),

                // AMBIENTE 3
                _buildModuleCard(
                  titulo: "Ambiente 3",
                  subtitulo: "Patrones",
                  icon: Icons.filter_3,
                  activo: _misNumeros[2] == null,
                  bloqueado: _misNumeros[1] == null,
                  onTap: () => _irAAmbiente(
                      2,
                      Ambiente1Screen(numerosExcluidos: numerosExistentes)
                  ),
                ),

                // AMBIENTE 4
                _buildModuleCard(
                  titulo: "Ambiente 4",
                  subtitulo: "Histórico",
                  icon: Icons.filter_4,
                  activo: _misNumeros[3] == null,
                  bloqueado: _misNumeros[2] == null,
                  onTap: () => _irAAmbiente(
                      3,
                      Ambiente1Screen(numerosExcluidos: numerosExistentes)
                  ),
                ),

                // AMBIENTE 5
                _buildModuleCard(
                  titulo: "Ambiente 5",
                  subtitulo: "Numerología",
                  icon: Icons.filter_5,
                  activo: _misNumeros[4] == null,
                  bloqueado: _misNumeros[3] == null,
                  onTap: () => _irAAmbiente(
                      4,
                      Ambiente1Screen(numerosExcluidos: numerosExistentes)
                  ),
                ),

                // SUPERBALOTA
                _buildModuleCard(
                  titulo: "Superbalota",
                  subtitulo: "El remate",
                  icon: Icons.star,
                  esSuper: true,
                  activo: _superBalota == null,
                  // Solo se desbloquea si ya llenaste los 5 números
                  bloqueado: _misNumeros.contains(null),
                  onTap: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuperBalotaScreen()),
                    );
                    if (resultado != null) {
                      setState(() {
                        _superBalota = resultado;
                      });
                      // --- CÓDIGO NUEVO: GUARDAR HISTORIAL AUTOMÁTICO ---
                      // Verificamos que tengamos los 5 números y la superbalota
                      if (!_misNumeros.contains(null) && _superBalota != null) {
                        final numerosLimpios = _misNumeros.whereType<int>().toList();
                        // Guardamos silenciosamente en segundo plano
                        HistoryService().guardarJugada(
                            numeros: numerosLimpios,
                            superBalota: _superBalota!
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("¡Ticket guardado en Historial! 💾"),
                              backgroundColor: Colors.green,
                            )
                        );
                      }
                      // ---------------------------------------------------
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
    required bool activo,
    required bool bloqueado,
    required VoidCallback onTap,
    bool esSuper = false,
  }) {
    // Está completado si no está activo (ya se jugó) y no estaba bloqueado previamente
    bool completado = !activo && !bloqueado;

    // Color especial para Superbalota o normal
    Color colorIcono = esSuper ? Colors.red : const Color(0xFF003366);
    if (bloqueado) colorIcono = Colors.grey;
    if (completado) colorIcono = Colors.green;

    return Opacity(
      opacity: bloqueado ? 0.5 : 1.0,
      child: Card(
        color: completado ? Colors.green[50] : Colors.white,
        elevation: bloqueado ? 0 : 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (bloqueado || completado) ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    completado ? Icons.check_circle : icon,
                    color: colorIcono,
                    size: 32
                ),
                const SizedBox(height: 8),
                Text(
                    titulo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: bloqueado ? Colors.grey : Colors.black87
                    )
                ),
                Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int numero, {bool esSuper = false}) {
    return Container(
      width: 45, height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
            color: esSuper ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
            width: 2
        ),
      ),
      child: Center(
        child: Text(
          esSuper ? 'S' : '$numero',
          style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}