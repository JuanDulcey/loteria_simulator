import 'package:flutter/material.dart';

class AppTheme {
  // Colores base
  static const Color primaryLight = Color(0xFF0F172A);
  static const Color primaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color accentLight = Color(0xFF003366);
  static const Color accentDark = Color(0xFF38BDF8); // Sky 400

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      surface: const Color(0xFFF5F7FA),
      background: const Color(0xFFF5F7FA),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryLight, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF334155)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentDark,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B), // Slate 800
      background: const Color(0xFF0F172A), // Slate 900
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E293B),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFFCBD5E1)), // Slate 300
    ),
  );
}
