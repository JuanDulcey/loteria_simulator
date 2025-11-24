import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar esto
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Historial de Operaciones'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Borrar todo',
            onPressed: () async {
              await _historyService.limpiarHistorial();
              _cargarData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Historial eliminado")),
                );
              }
            },
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
            return _buildEmptyState();
          }

          final lista = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = lista[index];
              final tipo = item['tipo'];

              if (tipo == 'JUGADA') {
                return _buildJugadaCard(item);
              } else {
                return _buildSimulacionCard(item);
              }
            },
          );
        },
      ),
    );
  }

  /// Tarjeta para Tickets Manuales
  Widget _buildJugadaCard(Map<String, dynamic> item) {
    // Parseamos los datos dinámicos a tipos seguros
    final numeros = List<int>.from(item['numeros']);
    final superBalota = item['superBalota'] as int;
    final fecha = DateTime.parse(item['fecha']);
    final fechaStr = DateFormat('MMM d, yyyy • h:mm a').format(fecha);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF003366)),
                  const SizedBox(width: 8),
                  Text(
                    "TICKET GENERADO",
                    style: TextStyle(
                      color: const Color(0xFF003366).withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(fechaStr, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...numeros.map((n) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: BalotaWidget(numero: n, size: 35),
              )),
              Container(width: 1, height: 30, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
              BalotaWidget(numero: superBalota, esSuperBalota: true, size: 35),
            ],
          ),
        ],
      ),
    );
  }

  /// Tarjeta para Simulaciones (Estadísticas)
  Widget _buildSimulacionCard(Map<String, dynamic> item) {
    final cantidad = item['cantidad'];
    final superHot = item['superHot'];
    final fecha = DateTime.parse(item['fecha']);
    final fechaStr = DateFormat('MMM d, h:mm a').format(fecha);

    // Recuperamos la lista de calientes
    final calientes = (item['topCalientes'] as List).map((e) => e as Map<String, dynamic>).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: Colors.purple.shade300, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(), // Quitar bordes internos
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
          child: Icon(Icons.analytics, color: Colors.purple.shade800),
        ),
        title: Text(
          "Simulación de $cantidad Sorteos",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(fechaStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Números más frecuentes en este lote:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...calientes.take(5).map((e) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          BalotaWidget(numero: e['n'], size: 30),
                          Text("${e['c']}x", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    )),
                    const Spacer(),
                    Column(
                      children: [
                        const Text("Super", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        BalotaWidget(numero: superHot, esSuperBalota: true, size: 30),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Sin historial aún",
            style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Genera tickets o realiza simulaciones\npara verlos aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}