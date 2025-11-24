import 'package:flutter/material.dart';

class BalotaWidget extends StatelessWidget {
  final int numero;
  final bool esSuperBalota;
  final double size;

  const BalotaWidget({
    super.key,
    required this.numero,
    this.esSuperBalota = false,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos colores para el efecto 3D
    final Color colorBase = esSuperBalota ? const Color(0xFFD32F2F) : const Color(0xFFFFD700);
    final Color colorBrillo = esSuperBalota ? const Color(0xFFFFCDD2) : const Color(0xFFFFFFE0);
    final Color colorSombra = esSuperBalota ? const Color(0xFF8B0000) : const Color(0xFFF57F17);
    final Color colorTexto = esSuperBalota ? Colors.white : Colors.black87;

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Sombra de la bola sobre la mesa
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 4),
            spreadRadius: 1,
          ),
        ],
        // Gradiente radial para efecto esférico
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4), // Punto de luz arriba a la izquierda
          radius: 1.0,
          colors: [
            colorBrillo.withOpacity(0.4), // Brillo especular
            colorBase,
            colorSombra,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Container(
        // Borde sutil interior para definición
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo blanco detrás del número para legibilidad (estilo bola de billar)
            Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
            // Número
            Text(
              '$numero',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black, // El número siempre negro sobre el círculo blanco
                fontSize: size * 0.35,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
