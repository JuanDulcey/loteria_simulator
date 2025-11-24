import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _keyHistorial = 'historial_baloto_premium';

  /// Guarda una JUGADA MANUAL (Ticket único)
  Future<void> guardarJugada({
    required List<int> numeros,
    required int superBalota,
  }) async {
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tipo': 'JUGADA', // Diferenciador
      'fecha': DateTime.now().toIso8601String(),
      'numeros': numeros,
      'superBalota': superBalota,
    };
    await _guardarEnLocal(entry);
  }

  /// Guarda una SIMULACIÓN MASIVA (Reporte de Dashboard)
  Future<void> guardarSimulacion({
    required int cantidad,
    required List<Map<String, dynamic>> topCalientes, // Solo guardamos el top 5 para no llenar memoria
    required int superBalotaMasFrecuente,
  }) async {
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tipo': 'SIMULACION',
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'topCalientes': topCalientes, // Guardamos JSON simplificado
      'superHot': superBalotaMasFrecuente,
    };
    await _guardarEnLocal(entry);
  }

  /// Método privado genérico para guardar
  Future<void> _guardarEnLocal(Map<String, dynamic> nuevaEntrada) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaActual = prefs.getStringList(_keyHistorial) ?? [];

    // Convertimos el mapa a texto JSON
    listaActual.add(jsonEncode(nuevaEntrada));

    // Guardamos
    await prefs.setStringList(_keyHistorial, listaActual);
  }

  /// Obtiene todo el historial ordenado por fecha (más reciente primero)
  Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaRaw = prefs.getStringList(_keyHistorial) ?? [];

    List<Map<String, dynamic>> historial = listaRaw.map((e) {
      return jsonDecode(e) as Map<String, dynamic>;
    }).toList();

    // Ordenar: Más nuevo arriba
    historial.sort((a, b) {
      DateTime fechaA = DateTime.parse(a['fecha']);
      DateTime fechaB = DateTime.parse(b['fecha']);
      return fechaB.compareTo(fechaA);
    });

    return historial;
  }

  /// Borra todo el historial del dispositivo
  Future<void> limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistorial);
    // Esto asegura que si entras al HistorialScreen, esté vacío
  }
}