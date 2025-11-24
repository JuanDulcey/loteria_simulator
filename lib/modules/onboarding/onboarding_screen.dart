import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../menu/menu_loterias_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState appState;

  const OnboardingScreen({super.key, required this.appState});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Bienvenido a Lotería Simulator",
      "description": "Tu herramienta profesional para simular y analizar sorteos de lotería colombiana.",
      "icon": "casino"
    },
    {
      "title": "Ambiente Aleatorio",
      "description": "Genera números totalmente al azar, tal como en un sorteo real. Ideal para probar tu suerte sin influencias.",
      "icon": "shuffle"
    },
    {
      "title": "Ambiente Estadístico",
      "description": "Utiliza datos históricos para generar combinaciones basadas en frecuencias y probabilidades.",
      "icon": "analytics"
    },
    {
      "title": "Ambiente de Patrones",
      "description": "Analiza secuencias y patrones repetitivos para sugerir números con mayor potencial.",
      "icon": "grid_on"
    },
    {
      "title": "¡Empieza a Ganar!",
      "description": "Configura tus preferencias, activa el modo oscuro y disfruta de la experiencia.",
      "icon": "rocket_launch"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(page['icon']!),
                            size: 80,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? colorScheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? "Comenzar" : "Siguiente"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishOnboarding() {
    widget.appState.completeOnboarding();
    // Since we are in main.dart changing home based on state, it should rebuild automatically.
    // However, if we pushed this screen, we should pop.
    // If we are at root (home: Onboarding), completeOnboarding triggers rebuild of main.dart
    // which switches home to MenuLoteriasScreen.
    // But AnimatedBuilder in main.dart should handle it.
    // If we were pushed from settings, we should pop.

    if (Navigator.canPop(context)) {
       Navigator.pop(context);
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'casino': return Icons.casino;
      case 'shuffle': return Icons.shuffle;
      case 'analytics': return Icons.analytics;
      case 'grid_on': return Icons.grid_on;
      case 'rocket_launch': return Icons.rocket_launch;
      default: return Icons.star;
    }
  }
}
