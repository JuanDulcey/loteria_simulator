import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/loteria_service.dart';
import '../../widgets/balota_widget.dart';
import '../../services/app_state.dart';

class SuperBalotaScreen extends StatefulWidget {
  final AppState? appState;

  const SuperBalotaScreen({super.key, this.appState});

  @override
  State<SuperBalotaScreen> createState() => _SuperBalotaScreenState();
}

class _SuperBalotaScreenState extends State<SuperBalotaScreen> with SingleTickerProviderStateMixin {
  final LoteriaService _loteriaService = LoteriaService();
  int? _superBalotaGenerada;
  bool _simulando = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _tempNumber = 1;
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _generarSuperBalota() async {
    setState(() {
      _simulando = true;
    });

    widget.appState?.playClick();

    // Start shuffling animation for super balota
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _tempNumber = Random().nextInt(16) + 1; // Baloto superbalota is 1-16
        });
        widget.appState?.vibrate();
      }
    });

    // Un poco más de suspenso para la final...
    await Future.delayed(const Duration(milliseconds: 2500));
    _shuffleTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _superBalotaGenerada = _loteriaService.generarSuperBalota();
      _simulando = false;
    });

    widget.appState?.vibrateSuccess();
    _animationController.forward(from: 0.0);
  }

  void _confirmarYSalir() {
    if (_superBalotaGenerada != null) {
      widget.appState?.playClick();
      Navigator.pop(context, _superBalotaGenerada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Superbalota'),
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
               ? [theme.scaffoldBackgroundColor, Colors.red.shade900.withValues(alpha : 0.3)]
               : [Colors.white, Colors.red.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡El Gran Final!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seleccionando balota del 1 al 16',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 50),

                // Área visual de la balota
                SizedBox(
                  height: 140,
                  child: _simulando
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red.shade300, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              "$_tempNumber",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent.shade700,
                              ),
                            ),
                          ),
                        )
                      : _superBalotaGenerada != null
                      ? Center(
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Transform.scale(
                              scale: 1.2,
                              child: BalotaWidget(
                                numero: _superBalotaGenerada!,
                                esSuperBalota: true,
                                size: 100,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.red.shade300, width: 2),
                            ),
                            child: Icon(Icons.star,
                                size: 50, color: Colors.red.shade300),
                          ),
                        ),
                ),

                const SizedBox(height: 60),

                // BOTONES CORREGIDOS
                if (_superBalotaGenerada == null)
                  ElevatedButton.icon(
                    onPressed: _simulando ? null : _generarSuperBalota,
                    icon: const Icon(Icons.bolt),
                    label: const Text(
                      'LANZAR SUPERBALOTA',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _confirmarYSalir,
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'FINALIZAR SORTEO',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
