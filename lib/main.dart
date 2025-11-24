import 'package:flutter/material.dart';
import 'modules/menu/menu_loterias_screen.dart';

void main() {
  runApp(const LoteriaSimulatorApp());
}

class LoteriaSimulatorApp extends StatelessWidget {
  const LoteriaSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotería Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        // Definimos una fuente predeterminada bonita si deseas
        // fontFamily: 'Roboto',
      ),
      // AHORA LA HOME ES EL MENÚ DE LOTERÍAS
      home: const MenuLoteriasScreen(),
    );
  }
}