import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/history_service.dart';
import '../../widgets/balota_widget.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<Map<String, dynamic>>> _futureHistorial;

  @override
  void initState() {
    super.initState();
    _cargarData();
  }

  void _cargarData() {
    setState(() {
      _futureHistorial = _historyService.obtenerHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'HISTORIAL DE TICKETS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent.shade200),
            tooltip: 'Limpiar Historial Local',
            onPressed: () => _confirmarBorrado(context),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureHistorial,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final lista = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              final tipo = item['tipo'];

              // Animación de entrada simple para cada tarjeta
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: tipo == 'JUGADA'
                    ? _buildTicketReal(item, isDark)
                    : _buildReporteSimulacion(item, isDark),
              );
            },
          );
        },
      ),
    );
  }

  /// 🎫 DISEÑO TIPO TICKET DE LOTERÍA (PREMIUM)
  Widget _buildTicketReal(Map<String, dynamic> item, bool isDark) {
    final numeros = List<int>.from(item['numeros']);
    final superBalota = item['superBalota'] as int;
    final fecha = DateTime.parse(item['fecha']);
    final fechaStr = DateFormat('dd MMM yyyy').format(fecha);
    final horaStr = DateFormat('hh:mm a').format(fecha);
    final origen = item['origen'] == 'nube' ? '☁️ Sincronizado' : '📱 Local';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // CABECERA DEL TICKET (Color Dorado/Azul)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [const Color(0xFF0F172A), Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "JUGADA MAESTRA",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  fechaStr.toUpperCase(),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // CUERPO DEL TICKET
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Fila de Balotas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Balotas Normales
                    ...numeros.map((n) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: BalotaWidget(numero: n, size: 38),
                    )),

                    // Separador vertical
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // Superbalota destacada
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10)
                          ]
                      ),
                      child: BalotaWidget(numero: superBalota, esSuperBalota: true, size: 42),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                const SizedBox(height: 12),

                // Footer con metadatos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      horaStr,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(
                        origen,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🧪 DISEÑO REPORTE DE LABORATORIO (TECNOLÓGICO)
  Widget _buildReporteSimulacion(Map<String, dynamic> item, bool isDark) {
    final cantidad = item['cantidad'];
    final superHot = item['superHot'];
    final fecha = DateTime.parse(item['fecha']);
    final fechaStr = DateFormat('MMM dd, hh:mm a').format(fecha);

    // Recuperamos la lista de calientes
    final calientes = (item['topCalientes'] as List).map((e) => e as Map<String, dynamic>).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: Colors.deepPurpleAccent.shade200, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(), // Quita bordes internos por defecto
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.science_outlined, color: Colors.deepPurpleAccent),
        ),
        title: Text(
          "SIMULACIÓN MASIVA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          "$cantidad sorteos analizados • $fechaStr",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  "RESULTADOS DEL EXPERIMENTO:",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lista de Calientes
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: calientes.take(5).map((e) => Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Column(
                            children: [
                              BalotaWidget(numero: e['n'], size: 32),
                              const SizedBox(height: 2),
                              Text("${e['c']}x", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    // Superbalota
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          const Text("REY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          const SizedBox(height: 2),
                          BalotaWidget(numero: superHot, esSuperBalota: true, size: 32),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_edu_rounded, size: 80, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            "Sin historial disponible",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey.shade600
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tus tickets guardados y simulaciones\naparecerán aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación para borrar
  Future<void> _confirmarBorrado(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Borrar historial local?"),
        content: const Text("Esto eliminará la lista de tu dispositivo. Los datos en la nube no se verán afectados."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _historyService.limpiarHistorial();
              _cargarData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Historial local limpio ✨")),
                );
              }
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}