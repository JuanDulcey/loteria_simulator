import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../services/loteria_service.dart';
import '../../../services/app_state.dart';
import '../../../widgets/balota_widget.dart';

enum TipoGeneracion {
  aleatorio,
  estadistico,
  patrones,
  historico,
  numerologia,
}

class GeneradorBalotaScreen extends StatefulWidget {
  final List<int> numerosExcluidos;
  final String titulo;
  final TipoGeneracion tipo;
  final Color colorTema;
  // We need to access AppState. Since I can't easily change the constructor signature everywhere without breaking things
  // unless I do it consistently.
  // I will add appState as a parameter.
  // If I can't modify the caller immediately, I'll have an issue.
  // Let's check BalotoScreen again. It calls GeneradorBalotaScreen constructor.
  // I will update BalotoScreen first? No, I am updating this file first.
  // I will add the parameter but make it optional to avoid immediate break, or just break it and fix caller next.
  // I'll break and fix caller.
  final AppState? appState;

  const GeneradorBalotaScreen({
    super.key,
    required this.numerosExcluidos,
    required this.titulo,
    required this.tipo,
    required this.colorTema,
    this.appState,
  });

  @override
  State<GeneradorBalotaScreen> createState() => _GeneradorBalotaScreenState();
}

class _GeneradorBalotaScreenState extends State<GeneradorBalotaScreen> with SingleTickerProviderStateMixin {
  final LoteriaService _loteriaService = LoteriaService();
  int? _numeroGenerado;
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
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _simularYGenerar() async {
    setState(() {
      _simulando = true;
    });

    widget.appState?.playClick();

    // Start shuffling animation
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _tempNumber = Random().nextInt(43) + 1; // Baloto goes up to 43 usually
        });
        widget.appState?.vibrate(); // Light vibration on shuffle
      }
    });

    // Simulación de "pensando" (delay estético)
    // Increase duration for dramatic effect
    await Future.delayed(const Duration(milliseconds: 2000));

    _shuffleTimer?.cancel();

    if (!mounted) return;

    setState(() {
      switch (widget.tipo) {
        case TipoGeneracion.aleatorio:
          _numeroGenerado = _loteriaService.generarNumeroUnico(widget.numerosExcluidos);
          break;
        case TipoGeneracion.estadistico:
          _numeroGenerado = _loteriaService.generarNumeroEstadistico(widget.numerosExcluidos);
          break;
        case TipoGeneracion.patrones:
          _numeroGenerado = _loteriaService.generarNumeroPatrones(widget.numerosExcluidos);
          break;
        case TipoGeneracion.historico:
          _numeroGenerado = _loteriaService.generarNumeroHistorico(widget.numerosExcluidos);
          break;
        case TipoGeneracion.numerologia:
          _numeroGenerado = _loteriaService.generarNumeroNumerologia(widget.numerosExcluidos);
          break;
      }
      _simulando = false;
    });

    // Play success sound/haptic
    widget.appState?.vibrateSuccess();
    _animationController.forward(from: 0.0);
  }

  void _confirmarYSalir() {
    if (_numeroGenerado != null) {
      widget.appState?.playClick();
      Navigator.pop(context, _numeroGenerado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: widget.colorTema,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _simulando ? 'Mezclando...' : 'Generando Balota',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Números prohibidos (ya jugados): ${widget.numerosExcluidos.isEmpty ? "Ninguno" : widget.numerosExcluidos.join(", ")}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),

            // Área de visualización
            SizedBox(
              height: 120,
              child: _simulando
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.colorTema.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.colorTema, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          "$_tempNumber",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: widget.colorTema
                          ),
                        ),
                      ),
                    )
                  : _numeroGenerado != null
                  ? ScaleTransition(
                      scale: _scaleAnimation,
                      child: BalotaWidget(numero: _numeroGenerado!, size: 100),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.question_mark, size: 50, color: Colors.grey),
                    ),
            ),

            const SizedBox(height: 50),

            // Botones Lógicos
            if (_numeroGenerado == null)
              ElevatedButton.icon(
                onPressed: _simulando ? null : _simularYGenerar,
                icon: const Icon(Icons.play_arrow),
                label: const Text('INICIAR SIMULACIÓN'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: widget.colorTema,
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _confirmarYSalir,
                icon: const Icon(Icons.check),
                label: const Text('CONFIRMAR ESTE NÚMERO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
