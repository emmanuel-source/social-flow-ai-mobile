import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('shows the initial onboarding value proposition', (tester) async {
    await tester.pumpWidget(_buildOnboarding());

    expect(find.text('Tous vos réseaux, un seul espace'), findsOneWidget);
    expect(find.text('Étape 1 sur 4'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('moves through pages and updates visible progress', (
    tester,
  ) async {
    await tester.pumpWidget(_buildOnboarding());

    await _tapNext(tester);
    expect(find.text('Créez plus vite avec l’IA'), findsOneWidget);
    expect(find.text('Étape 2 sur 4'), findsOneWidget);

    await _tapNext(tester);
    expect(find.text('Planifiez sans friction'), findsOneWidget);
    expect(find.text('Étape 3 sur 4'), findsOneWidget);
  });

  testWidgets('shows final CTA and completes the onboarding', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      _buildOnboarding(onCompleted: () async => completions++),
    );

    await _reachLastStep(tester);
    expect(find.text('Mesurez ce qui fonctionne'), findsOneWidget);
    expect(find.text('Étape 4 sur 4'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Passer'), findsNothing);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(completions, 1);
  });

  testWidgets('skip uses the same completion contract', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      _buildOnboarding(onCompleted: () async => completions++),
    );

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(completions, 1);
  });

  testWidgets('progress indicator exposes essential semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_buildOnboarding());

    expect(find.bySemanticsLabel(RegExp('Social Flow AI')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('Étape 1 sur 4')), findsWidgets);
    expect(
      find.bySemanticsLabel(
        RegExp('Réseaux sociaux réunis dans un espace unique'),
      ),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('compact width and enlarged text do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildOnboarding(textScaleFactor: 1.6));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('renders in light and dark themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildOnboarding(themeMode: mode));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(OnboardingScreen));
      expect(
        Theme.of(context).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _buildOnboarding({
  Future<void> Function()? onCompleted,
  ThemeMode themeMode = ThemeMode.light,
  double textScaleFactor = 1,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    builder:
        (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: child!,
        ),
    home: OnboardingScreen(onCompleted: onCompleted ?? () async {}),
  );
}

Future<void> _tapNext(WidgetTester tester) async {
  await tester.tap(find.text('Suivant'));
  await tester.pumpAndSettle();
}

Future<void> _reachLastStep(WidgetTester tester) async {
  for (var index = 1; index < OnboardingScreen.stepCount; index++) {
    await _tapNext(tester);
  }
}
