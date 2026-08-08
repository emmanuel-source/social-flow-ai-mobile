import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/shared/widgets/app_buttons.dart';
import 'package:socialflow_ai/shared/widgets/app_text_fields.dart';

import 'widget_test_harness.dart';

void main() {
  testWidgets('primary button handles action, loading and disabled states', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      buildTestApp(
        Column(
          children: [
            AppPrimaryButton(
              label: 'Créer une publication',
              onPressed: () => presses++,
            ),
            const AppPrimaryButton(
              label: 'Publication en cours',
              onPressed: null,
              loading: true,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Créer une publication'));
    expect(presses, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('button variants render in dark mode with long labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Column(
          children: [
            AppSecondaryButton(
              label: 'Action secondaire avec un libellé volontairement long',
              onPressed: () {},
            ),
            AppTertiaryButton(label: 'En savoir plus', onPressed: () {}),
            AppIconButton(
              icon: Icons.settings,
              tooltip: 'Ouvrir les paramètres',
              onPressed: () {},
            ),
          ],
        ),
        themeMode: ThemeMode.dark,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Ouvrir les paramètres'), findsOneWidget);
  });

  testWidgets(
    'password visibility and search clear affordances are accessible',
    (tester) async {
      final passwordController = TextEditingController(text: 'secret');
      addTearDown(passwordController.dispose);
      await tester.pumpWidget(
        buildTestApp(
          ListView(
            children: [
              AppPasswordField(
                label: 'Mot de passe',
                controller: passwordController,
              ),
              AppSearchField(onChanged: (_) {}, onClear: () {}),
            ],
          ),
        ),
      );

      final passwordField = find.descendant(
        of: find.byType(AppPasswordField),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
      await tester.tap(find.byTooltip('Afficher le mot de passe'));
      await tester.pump();
      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
      expect(find.byTooltip('Effacer la recherche'), findsOneWidget);
    },
  );
}
