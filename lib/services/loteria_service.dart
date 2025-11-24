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