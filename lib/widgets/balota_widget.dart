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
    // Amarillo para normales, Rojo oscuro para superbalota
    final Color colorFondo = esSuperBalota ? const Color(0xFFD32F2F) : const Color(0xFFFFD700);
    final Color colorTexto = esSuperBalota ? Colors.white : Colors.black87;

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: size * 0.05,
        ),
      ),
      child: Center(
        child: Text(
          '$numero',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorTexto,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}