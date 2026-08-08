import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';
import 'package:socialflow_ai/shared/widgets/app_state_view.dart';

import 'widget_test_harness.dart';

void main() {
  testWidgets('empty, error and success states support actions', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      buildTestApp(
        ListView(
          children: [
            AppEmptyState(
              title: 'Aucun contenu',
              message: 'Créez votre première publication.',
              actionLabel: 'Créer',
              onAction: () => actions++,
            ),
            AppErrorState(
              title: 'Chargement impossible',
              message: 'Vérifiez votre connexion.',
              onRetry: () => actions++,
            ),
            const AppSuccessState(
              title: 'Publication prête',
              message: 'Votre contenu est enregistré.',
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Créer'));
    await tester.tap(find.text('Réessayer'));
    expect(actions, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation primitive exposes destinations and selection', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      buildTestApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: StatefulBuilder(
            builder:
                (context, setState) => AppNavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (value) {
                    setState(() => selected = value);
                  },
                  destinations: const [
                    AppNavigationDestination(
                      label: 'Accueil',
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                    ),
                    AppNavigationDestination(
                      label: 'Créer',
                      icon: Icons.add_box_outlined,
                      selectedIcon: Icons.add_box,
                    ),
                  ],
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Créer'));
    await tester.pump();
    expect(selected, 1);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
