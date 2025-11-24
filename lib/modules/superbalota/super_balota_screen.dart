import 'package:flutter/material.dart';
import '../../services/loteria_service.dart';
import '../../widgets/balota_widget.dart';

class SuperBalotaScreen extends StatefulWidget {
  const SuperBalotaScreen({super.key});

  @override
  State<SuperBalotaScreen> createState() => _SuperBalotaScreenState();
}

class _SuperBalotaScreenState extends State<SuperBalotaScreen> {
  final LoteriaService _loteriaService = LoteriaService();
  int? _superBalotaGenerada;
  bool _simulando = false;

  void _generarSuperBalota() async {
    setState(() {
      _simulando = true;
    });

    // Un poco más de suspenso para la final...
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _superBalotaGenerada = _loteriaService.generarSuperBalota();
      _simulando = false;
    });
  }

  void _confirmarYSalir() {
    if (_superBalotaGenerada != null) {
      Navigator.pop(context, _superBalotaGenerada);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            colors: [Colors.white, Colors.red.shade50],
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
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent.shade700,
                    ),
                  )
                      : _superBalotaGenerada != null
                      ? Center(
                    child: Transform.scale(
                      scale: 1.2,
                      child: BalotaWidget(
                        numero: _superBalotaGenerada!,
                        esSuperBalota: true,
                        size: 100,
                      ),
                    ),
                  )
                      : Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
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
                // Quitamos 'textStyle' de styleFrom y lo pasamos al Text()
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
                      // HEMOS ELIMINADO 'textStyle' DE AQUÍ PARA EVITAR EL ERROR
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