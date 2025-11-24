import 'package:flutter/material.dart';
import '../../services/loteria_service.dart';
import '../../widgets/balota_widget.dart';

class Ambiente1Screen extends StatefulWidget {
  // Recibimos la lista de números que YA salieron para no repetirlos
  final List<int> numerosExcluidos;

  const Ambiente1Screen({
    super.key,
    required this.numerosExcluidos,
  });

  @override
  State<Ambiente1Screen> createState() => _Ambiente1ScreenState();
}

class _Ambiente1ScreenState extends State<Ambiente1Screen> {
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
      _numeroGenerado = _loteriaService.generarNumeroUnico(widget.numerosExcluidos);
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
        title: const Text('Ambiente 1: Aleatorio'),
        backgroundColor: Colors.indigo,
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
                  ? const Center(child: CircularProgressIndicator())
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