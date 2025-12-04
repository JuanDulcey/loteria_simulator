import 'package:flutter/material.dart';
import '../../services/simulation_service.dart';
import '../../services/history_service.dart';
import '../../widgets/balota_widget.dart';

class BalotoDashboardScreen extends StatefulWidget {
  const BalotoDashboardScreen({super.key});

  @override
  State<BalotoDashboardScreen> createState() => _BalotoDashboardScreenState();
}

class _BalotoDashboardScreenState extends State<BalotoDashboardScreen> {
  final SimulationService _simService = SimulationService();
  // Instanciamos HistoryService para guardar resultados localmente
  final HistoryService _historyService = HistoryService();

  bool _cargando = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _actualizarStats();
  }

  void _actualizarStats() {
    setState(() {
      _stats = _simService.obtenerEstadisticas();
    });
  }

  Future<void> _ejecutarSimulacion(int cantidad) async {
    setState(() => _cargando = true);

    // 1. LIMPIEZA PREVIA (RAM)
    // Para que el lote sea estadísticamente puro y nuevo.
    _simService.limpiarHistorial();

    // 2. EJECUTAR SIMULACIÓN MATEMÁTICA
    await _simService.simularLote(cantidad);

    // 3. PREPARAR DATOS
    final nuevasStats = _simService.obtenerEstadisticas();

    // Convertimos la lista a un formato seguro para JSON
    final topCalientes = (nuevasStats['calientes'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final superHot = nuevasStats['superHot'] as int;

    // 4. GUARDAR SOLO EN LOCAL (No toca la nube)
    await _historyService.guardarSimulacion(
        cantidad: cantidad,
        topCalientes: topCalientes,
        superBalotaMasFrecuente: superHot
    );

    // 5. ACTUALIZAR UI
    _actualizarStats();
    setState(() => _cargando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡$cantidad sorteos analizados y guardados localmente!')),
      );
    }
  }

  void _limpiarData() async {
    // Borrar RAM
    _simService.limpiarHistorial();
    _actualizarStats();

    // Borrar Disco Local (SharedPreferences)
    // NOTA: Esto no borra los tickets que subiste a Firestore.
    await _historyService.limpiarHistorial();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('♻️ Historial local eliminado'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalJugadas = _stats['total'] ?? 0;
    final List calientes = _stats['calientes'] ?? [];
    final List frios = _stats['frios'] ?? [];
    final int superHot = _stats['superHot'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio de Datos'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _limpiarData,
            tooltip: 'Borrar historial local',
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _cargando
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text("Procesando datos frescos...", style: TextStyle(color: Colors.indigo.shade900)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CONTROLES ---
            const Text("Simulación Masiva", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSimButton(10),
                _buildSimButton(100),
                _buildSimButton(1000),
                _buildSimButton(10000),
              ],
            ),

            const SizedBox(height: 25),

            // --- RESUMEN ---
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.science, size: 40, color: Colors.indigo.shade900),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lote Actual Analizado", style: TextStyle(color: Colors.grey[600])),
                        Text(
                            "$totalJugadas",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- ESTADÍSTICAS ---
            if (totalJugadas > 0) ...[
              const Text("Tendencias de este lote", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              // Calientes
              _buildStatCard(
                title: "Números Calientes 🔥",
                subtitle: "Mayor frecuencia en este lote",
                colorHeader: Colors.orange.shade800,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: calientes.map((e) => _buildMiniBalota(e['n'], e['c'])).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Fríos
              _buildStatCard(
                title: "Números Fríos ❄️",
                subtitle: "Menor frecuencia en este lote",
                colorHeader: Colors.blue.shade700,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: frios.map((e) => _buildMiniBalota(e['n'], e['c'])).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Superbalota
              _buildStatCard(
                title: "Superbalota Rey 👑",
                subtitle: "La reina de este lote",
                colorHeader: Colors.purple.shade700,
                content: Center(
                  child: BalotaWidget(numero: superHot, esSuperBalota: true, size: 60),
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Icons.query_stats, size: 50, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        "Selecciona una cantidad para\niniciar un nuevo experimento",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimButton(int cantidad) {
    return ElevatedButton(
      onPressed: () => _ejecutarSimulacion(cantidad),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text("+$cantidad", style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatCard({required String title, required String subtitle, required Color colorHeader, required Widget content}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorHeader,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalota(int numero, int cantidad) {
    return Column(
      children: [
        BalotaWidget(numero: numero, size: 35),
        const SizedBox(height: 4),
        Text("$cantidad", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}