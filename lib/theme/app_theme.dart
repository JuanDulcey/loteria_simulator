import 'package:flutter/material.dart';

class AppTheme {
  // Colores base
  static const Color primaryLight = Color(0xFF0F172A);
  static const Color primaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color accentLight = Color(0xFF003366);
  static const Color accentDark = Color(0xFF38BDF8); // Sky 400

  // ----------------------------------------------------------
  // TEMA CLARO (LIGHT)
  // ----------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // DEFINICIÓN DE COLORES
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      // ESTRATEGIA: Surface blanco para que las Cards sean blancas por defecto
      surface: Colors.white,
    ),

    // Fondo gris claro para contraste
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    // BARRA DE NAVEGACIÓN
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    // NOTA: Hemos eliminado 'cardTheme' para evitar el conflicto de tipos.
    // El estilo de las tarjetas se manejará por defecto con el ColorScheme.surface (Blanco)
    // y las sombras/bordes definidos en los widgets individuales.

    // TEXTOS
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryLight, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF334155)),
    ),
  );

  // ----------------------------------------------------------
  // TEMA OSCURO (DARK)
  // ----------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: accentDark,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B),
    ),

    scaffoldBackgroundColor: const Color(0xFF0F172A),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFFCBD5E1)), // Slate 300
    ),
  );
}