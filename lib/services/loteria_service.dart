import 'dart:math';

class LoteriaService {
  final Random _random = Random();

  // --- MÉTODOS DE JUEGO PASO A PASO (UI) ---

  int generarNumeroUnico(List<int> excluidos) {
    int numero;
    do {
      numero = _random.nextInt(43) + 1;
    } while (excluidos.contains(numero));
    return numero;
  }

  /// Ambiente 2: Estadístico
  int generarNumeroEstadistico(List<int> excluidos) {
    return generarNumeroUnico(excluidos);
  }

  /// Ambiente 3: Patrones
  int generarNumeroPatrones(List<int> excluidos) {
    return generarNumeroUnico(excluidos);
  }

  /// Ambiente 4: Histórico
  int generarNumeroHistorico(List<int> excluidos) {
    return generarNumeroUnico(excluidos);
  }

  /// Ambiente 5: Numerología
  int generarNumeroNumerologia(List<int> excluidos) {
    return generarNumeroUnico(excluidos);
  }

  // --- MÉTODOS DE SIMULACIÓN MASIVA (DASHBOARD) ---

  List<int> generarNumerosPrincipales() {
    final Set<int> numeros = {};

    // Usamos Set para garantizar unicidad automática
    while (numeros.length < 5) {
      int numero = _random.nextInt(43) + 1;
      numeros.add(numero);
    }

    // Retornamos la lista ordenada para facilitar el análisis
    final List<int> listaOrdenada = numeros.toList()..sort();
    return listaOrdenada;
  }

  // --- SUPERBALOTA ---

  int generarSuperBalota() {
    return _random.nextInt(16) + 1;
  }
}