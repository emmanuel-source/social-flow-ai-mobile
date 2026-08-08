import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/shared/widgets/app_bottom_sheet.dart';
import 'package:socialflow_ai/shared/widgets/app_dialog.dart';
import 'package:socialflow_ai/shared/widgets/app_loader.dart';
import 'package:socialflow_ai/shared/widgets/app_tabs.dart';

import 'widget_test_harness.dart';

void main() {
  testWidgets('confirmation dialog returns the selected decision', (
    tester,
  ) async {
    bool? decision;
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  decision = await AppDialog.confirm(
                    context: context,
                    title: 'Supprimer le brouillon ?',
                    message: 'Cette action ne peut pas être annulée.',
                    confirmLabel: 'Supprimer',
                    destructive: true,
                  );
                },
                child: const Text('Ouvrir le dialogue'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir le dialogue'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer le brouillon ?'), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(decision, isTrue);
  });

  testWidgets('bottom sheet respects safe layout and keyboard-ready content', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => AppBottomSheet.show<void>(
                      context: context,
                      title: 'Programmer la publication',
                      child: const Text('Choisissez une date et une heure.'),
                    ),
                child: const Text('Ouvrir la feuille'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir la feuille'));
    await tester.pumpAndSettle();
    expect(find.text('Programmer la publication'), findsOneWidget);
    expect(find.text('Choisissez une date et une heure.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs and loader expose readable labels', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const DefaultTabController(
          length: 3,
          child: Column(
            children: [
              AppTabs(tabs: ['Tout', 'Programmé', 'Publié']),
              AppLoader(label: 'Chargement des publications'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Programmé'), findsOneWidget);
    expect(find.text('Chargement des publications'), findsOneWidget);
  });
}
