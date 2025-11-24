import 'dart:math';

class LoteriaService {
  final Random _random = Random();

  /// MÉTODO 1: Para el juego paso a paso (Ambientes)
  /// Genera un solo número asegurando que no esté en la lista de excluidos.
  int generarNumeroUnico(List<int> excluidos) {
    int numero;
    do {
      numero = _random.nextInt(43) + 1;
    } while (excluidos.contains(numero));
    return numero;
  }

  /// Genera un número "Estadístico" (Por ahora, similar a aleatorio pero placeholder para lógica futura)
  int generarNumeroEstadistico(List<int> excluidos) {
    // TODO: Implementar lógica basada en estadísticas reales o simuladas
    return generarNumeroUnico(excluidos);
  }

  /// Genera un número basado en "Patrones"
  int generarNumeroPatrones(List<int> excluidos) {
    // TODO: Implementar lógica de patrones (e.g., pares/impares, sumas)
    return generarNumeroUnico(excluidos);
  }

  /// Genera un número basado en "Histórico"
  int generarNumeroHistorico(List<int> excluidos) {
    // TODO: Implementar lógica basada en historial de sorteos pasados
    return generarNumeroUnico(excluidos);
  }

  /// Genera un número basado en "Numerología"
  int generarNumeroNumerologia(List<int> excluidos) {
    // TODO: Implementar lógica de numerología
    return generarNumeroUnico(excluidos);
  }

  /// MÉTODO 2: Para el Dashboard (Simulación Masiva)
  /// Genera los 5 números de golpe, ordenados y sin repetir.
  List<int> generarNumerosPrincipales() {
    final Set<int> numeros = {};

    while (numeros.length < 5) {
      int numero = _random.nextInt(43) + 1;
      numeros.add(numero);
    }

    final List<int> listaOrdenada = numeros.toList()..sort();
    return listaOrdenada;
  }

  /// MÉTODO 3: Superbalota (Común para ambos)
  int generarSuperBalota() {
    return _random.nextInt(16) + 1;
  }
}
