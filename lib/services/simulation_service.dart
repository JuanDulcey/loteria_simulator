import 'loteria_service.dart';

class SimulationService {
  // Singleton para mantener los datos en memoria mientras la app está abierta
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;
  SimulationService._internal();

  final LoteriaService _loteriaService = LoteriaService();

  // Base de datos local en memoria (Aquí se guardan las jugadas)
  List<Map<String, dynamic>> _historialSimulaciones = [];

  // Getters
  int get totalSimulaciones => _historialSimulaciones.length;

  /// Simula una cantidad específica de sorteos (Batch)
  Future<void> simularLote(int cantidad) async {
    // Simulamos un pequeño delay para que la UI no se congele si son 10,000
    await Future.delayed(const Duration(milliseconds: 100));

    for (int i = 0; i < cantidad; i++) {
      // Usamos el servicio existente para respetar las reglas
      final numeros = _loteriaService.generarNumerosPrincipales();
      final superBalota = _loteriaService.generarSuperBalota();

      _historialSimulaciones.add({
        'numeros': numeros,
        'superBalota': superBalota,
        'fecha': DateTime.now(),
      });
    }
  }

  /// Borra todo el historial
  void limpiarHistorial() {
    _historialSimulaciones.clear();
  }

  /// Calcula estadísticas avanzadas
  Map<String, dynamic> obtenerEstadisticas() {
    if (_historialSimulaciones.isEmpty) return {};

    Map<int, int> frecuenciaNumeros = {};
    Map<int, int> frecuenciaSuper = {};

    // 1. Conteo de frecuencias
    for (var sorteo in _historialSimulaciones) {
      List<int> nums = sorteo['numeros'];
      int superB = sorteo['superBalota'];

      // Contar números principales (1-43)
      for (var n in nums) {
        frecuenciaNumeros[n] = (frecuenciaNumeros[n] ?? 0) + 1;
      }

      // Contar superbalotas (1-16)
      frecuenciaSuper[superB] = (frecuenciaSuper[superB] ?? 0) + 1;
    }

    // 2. Ordenar para sacar calientes y fríos
    var numerosOrdenados = frecuenciaNumeros.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // De mayor a menor

    var superOrdenadas = frecuenciaSuper.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 3. Preparar retorno
    return {
      'total': _historialSimulaciones.length,
      // Top 5 Calientes (Más salen)
      'calientes': numerosOrdenados.take(5).map((e) => {'n': e.key, 'c': e.value}).toList(),
      // Top 5 Fríos (Menos salen - tomamos del final de la lista)
      'frios': numerosOrdenados.reversed.take(5).map((e) => {'n': e.key, 'c': e.value}).toList(),
      // Superbalota más común
      'superHot': superOrdenadas.isNotEmpty ? superOrdenadas.first.key : 0,
    };
  }
}