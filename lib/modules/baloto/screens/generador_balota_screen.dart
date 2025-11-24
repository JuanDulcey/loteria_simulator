import 'package:flutter/material.dart';
import '../../../services/loteria_service.dart';
import '../../../widgets/balota_widget.dart';

enum TipoGeneracion {
  aleatorio,
  estadistico,
  patrones,
  historico,
  numerologia,
}

class GeneradorBalotaScreen extends StatefulWidget {
  // Recibimos la lista de números que YA salieron para no repetirlos
  final List<int> numerosExcluidos;
  final String titulo;
  final TipoGeneracion tipo;
  final Color colorTema;

  const GeneradorBalotaScreen({
    super.key,
    required this.numerosExcluidos,
    required this.titulo,
    required this.tipo,
    required this.colorTema,
  });

  @override
  State<GeneradorBalotaScreen> createState() => _GeneradorBalotaScreenState();
}

class _GeneradorBalotaScreenState extends State<GeneradorBalotaScreen> {
  final LoteriaService _loteriaService = LoteriaService();
  int? _numeroGenerado;
  bool _simulando = false;

  void _simularYGenerar() async {
    setState(() {
      _simulando = true;
    });

    // Simulación de "pensando" (delay estético)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      // Aquí ocurre la magia: pedimos un número que NO esté en la lista de excluidos
      // Dependiendo del tipo, llamamos al servicio correspondiente
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
  }

  void _confirmarYSalir() {
    if (_numeroGenerado != null) {
      // Devolvemos el número a la pantalla Home
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
            const Text(
              'Generando Balota',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  ? Center(child: CircularProgressIndicator(color: widget.colorTema))
                  : _numeroGenerado != null
                  ? BalotaWidget(numero: _numeroGenerado!, size: 100)
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
                onPressed: _simularYGenerar,
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
