import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/storage/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _items = [
    (
      Icons.auto_awesome,
      'Créez du contenu qui marque',
      'Générez des idées, rédigez, éditez et adaptez vos contenus pour toutes les plateformes.',
    ),
    (
      Icons.calendar_month,
      'Planifiez au bon moment',
      'Programmez et gérez vos publications depuis un calendrier intelligent.',
    ),
    (
      Icons.smart_toy_outlined,
      'Laissez vos agents travailler',
      'Automatisez les tâches répétitives tout en gardant le contrôle.',
    ),
  ];

  Future<void> _next() async {
    if (_index < _items.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }
    await LocalStorage.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemCount: _items.length,
                  itemBuilder: (_, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 180,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            item.$1,
                            size: 62,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.$3,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          i == _index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _next,
                child: Text(_index == 2 ? 'Commencer' : 'Suivant'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                child: const Text('Passer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
