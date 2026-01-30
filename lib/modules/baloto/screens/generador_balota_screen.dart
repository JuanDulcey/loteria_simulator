import 'package:flutter/material.dart';
import 'dart:async';
import '../../../widgets/balota_widget.dart';
import '../../../services/loteria_service.dart';
import '../../../services/app_state.dart';

// Enum para identificar qué lógica usar
enum TipoGeneracion { aleatorio, estadistico, patrones, historico, numerologia }

class GeneradorBalotaScreen extends StatefulWidget {
  final List<int> numerosExcluidos;
  final String titulo;
  final TipoGeneracion tipo;
  final Color colorTema;
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
  bool _isSimulating = false;

  // Animación
  int _numeroAnimacion = 0;
  Timer? _timerAnimacion;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Controlador para el efecto de "rebote" al aparecer la balota
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _timerAnimacion?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _iniciarSimulacion() async {
    if (_isSimulating) return;

    setState(() {
      _isSimulating = true;
      _numeroGenerado = null;
    });

    widget.appState?.playClick();

    // 1. Animación visual (Barajar números rápidamente)
    _timerAnimacion = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _numeroAnimacion = _loteriaService.generarNumeroUnico([]);
        });
      }
    });

    // 2. Tiempo de espera para suspenso (1.5 segundos)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Detener animación
    _timerAnimacion?.cancel();

    if (!mounted) return;

    // 4. Seleccionar lógica matemática real según el tipo
    int resultadoFinal = 1;
    switch (widget.tipo) {
      case TipoGeneracion.aleatorio:
        resultadoFinal = _loteriaService.generarNumeroUnico(widget.numerosExcluidos);
        break;
      case TipoGeneracion.estadistico:
        resultadoFinal = _loteriaService.generarNumeroEstadistico(widget.numerosExcluidos);
        break;
      case TipoGeneracion.patrones:
        resultadoFinal = _loteriaService.generarNumeroPatrones(widget.numerosExcluidos);
        break;
      case TipoGeneracion.historico:
        resultadoFinal = _loteriaService.generarNumeroHistorico(widget.numerosExcluidos);
        break;
      case TipoGeneracion.numerologia:
        resultadoFinal = _loteriaService.generarNumeroNumerologia(widget.numerosExcluidos);
        break;
    }

    // 5. Mostrar resultado con éxito
    widget.appState?.vibrateSuccess();
    setState(() {
      _numeroGenerado = resultadoFinal;
      _isSimulating = false;
    });
    _animController.forward(from: 0.0);
  }

  void _confirmarSeleccion() {
    if (_numeroGenerado != null) {
      widget.appState?.playClick();
      Navigator.pop(context, _numeroGenerado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.colorTema,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- SECCIÓN DE NÚMEROS YA JUGADOS (HISTORIAL VISUAL) ---
              if (widget.numerosExcluidos.isNotEmpty) ...[
                Text(
                  "Números bloqueados (ya jugados):",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: widget.numerosExcluidos
                      .map((n) => Chip(
                    label: Text('$n', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 40),
              ],

              // --- ÁREA DE GENERACIÓN (CÍRCULO CENTRAL) ---
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: widget.colorTema.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    )
                  ],
                  border: Border.all(
                    color: _isSimulating ? widget.colorTema : Colors.grey.withOpacity(0.2),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: _isSimulating
                      ? Text(
                    '$_numeroAnimacion',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      fontFamily: 'Monospace', // Estilo digital
                    ),
                  )
                      : _numeroGenerado != null
                      ? ScaleTransition(
                    scale: _scaleAnimation,
                    child: BalotaWidget(numero: _numeroGenerado!, size: 130),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 50, color: Colors.grey[300]),
                      const SizedBox(height: 5),
                      Text("Iniciar", style: TextStyle(color: Colors.grey[400]))
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // --- BOTONES DE ACCIÓN ---
              if (_numeroGenerado == null)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSimulating ? null : _iniciarSimulacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colorTema,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: _isSimulating
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Icon(Icons.play_arrow_rounded, size: 30),
                    label: Text(
                      _isSimulating ? "  CALCULANDO..." : "GENERAR NÚMERO",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _confirmarSeleccion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 28),
                        label: const Text(
                          "CONFIRMAR ESTE NÚMERO",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton.icon(
                      onPressed: _iniciarSimulacion,
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Probar otra vez"),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}