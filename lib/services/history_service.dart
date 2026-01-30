import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _keyHistorial = 'historial_baloto_premium';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ----------------------------------------------------------------------
  // 1. SINCRONIZACIÓN (LOGIN)
  // ----------------------------------------------------------------------

  Future<void> sincronizarDesdeNube() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("Iniciando sincronización con la nube...");

      final querySnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('tickets')
          .orderBy('timestamp', descending: true)
          .get();

      final prefs = await SharedPreferences.getInstance();
      List<String> listaLocalRaw = prefs.getStringList(_keyHistorial) ?? [];

      List<Map<String, dynamic>> listaLocal = listaLocalRaw.map((e) {
        return jsonDecode(e) as Map<String, dynamic>;
      }).toList();

      int agregados = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        bool existe = listaLocal.any((item) => item['id'] == data['id']);

        if (!existe) {
          final nuevoItem = {
            'id': data['id'],
            'tipo': data['tipo'] ?? 'JUGADA',
            'fecha': data['fecha'],
            'numeros': List<int>.from(data['numeros']),
            'superBalota': data['superBalota'],
            'origen': data['origen'] ?? 'nube',
          };

          listaLocal.add(nuevoItem);
          agregados++;
        }
      }

      if (agregados > 0) {
        List<String> nuevaListaString = listaLocal.map((e) => jsonEncode(e)).toList();
        await prefs.setStringList(_keyHistorial, nuevaListaString);
        debugPrint("Sincronización completa: $agregados tickets descargados.");
      } else {
        debugPrint("Sincronización completa: No había tickets nuevos.");
      }

    } catch (e) {
      debugPrint("Error sincronizando: $e");
    }
  }

  // ----------------------------------------------------------------------
  // 2. GUARDAR JUGADA
  // ----------------------------------------------------------------------
  Future<void> guardarJugada({
    required List<int> numeros,
    required int superBalota,
  }) async {
    final fecha = DateTime.now();

    final entry = {
      'id': fecha.millisecondsSinceEpoch.toString(),
      'tipo': 'JUGADA',
      'fecha': fecha.toIso8601String(),
      'numeros': numeros,
      'superBalota': superBalota,
      'origen': 'app_widgets',
    };

    // A. Local
    await _guardarEnLocal(entry);

    // B. Nube
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('tickets')
            .doc(entry['id'] as String)
            .set({
          ...entry,
          'timestamp': FieldValue.serverTimestamp(),
          'meta_suma': numeros.reduce((a, b) => a + b),
          'meta_pares': numeros.where((n) => n.isEven).length,
          'meta_impares': numeros.where((n) => n.isOdd).length,
        });

        debugPrint("Ticket subido y sincronizado en la nube");
      } catch (e) {
        debugPrint("Error nube: $e");
      }
    }
  }

  // ----------------------------------------------------------------------
  // 3. GUARDAR SIMULACIÓN (Solo Local)
  // ----------------------------------------------------------------------
  Future<void> guardarSimulacion({
    required int cantidad,
    required List<Map<String, dynamic>> topCalientes,
    required int superBalotaMasFrecuente,
  }) async {
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tipo': 'SIMULACION',
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'topCalientes': topCalientes,
      'superHot': superBalotaMasFrecuente,
    };
    await _guardarEnLocal(entry);
  }

  // ----------------------------------------------------------------------
  // 4. MÉTODOS LOCALES
  // ----------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaRaw = prefs.getStringList(_keyHistorial) ?? [];

    List<Map<String, dynamic>> historial = listaRaw.map((e) {
      return jsonDecode(e) as Map<String, dynamic>;
    }).toList();

    historial.sort((a, b) {
      DateTime fechaA = DateTime.parse(a['fecha']);
      DateTime fechaB = DateTime.parse(b['fecha']);
      return fechaB.compareTo(fechaA);
    });
    return historial;
  }

  Future<void> limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistorial);
    debugPrint("Historial local eliminado por cierre de sesión.");
  }

  Future<void> _guardarEnLocal(Map<String, dynamic> nuevaEntrada) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaActual = prefs.getStringList(_keyHistorial) ?? [];
    listaActual.add(jsonEncode(nuevaEntrada));
    await prefs.setStringList(_keyHistorial, listaActual);
  }
}