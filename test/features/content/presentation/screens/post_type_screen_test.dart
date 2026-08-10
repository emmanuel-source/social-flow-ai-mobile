import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/create_hub_screen.dart';
import 'package:socialflow_ai/features/content/presentation/screens/post_type_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  testWidgets('renders the initial publication type hierarchy', (tester) async {
    await _pumpScreen(tester);

    expect(find.text('Créer une publication'), findsOneWidget);
    expect(find.text('Étape 1 · Type de contenu'), findsOneWidget);
    expect(find.text('Étape 1'), findsOneWidget);
  });

  testWidgets('shows the creation question and platform guidance', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(
      find.text('Quel type de contenu souhaitez-vous créer ?'),
      findsOneWidget,
    );
    expect(
      find.textContaining('plateformes seront sélectionnées'),
      findsOneWidget,
    );
  });

  for (final option in <(String, String)>[
    ('Texte', 'Partagez une idée, une actualité ou un conseil.'),
    ('Photo', 'Publiez une image accompagnée de votre message.'),
    ('Vidéo', 'Créez une vidéo adaptable à plusieurs plateformes.'),
    ('Carrousel', 'Présentez plusieurs images dans une même publication.'),
  ]) {
    testWidgets('shows ${option.$1} with a useful description', (tester) async {
      await _pumpScreen(tester);

      expect(find.text(option.$1), findsOneWidget);
      expect(find.text(option.$2), findsOneWidget);
    });
  }

  testWidgets('starts without a selected type and disables Continue', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.text('Sélectionné'), findsNothing);
    expect(_continueButton(tester).onPressed, isNull);
  });

  for (final option in <(String, PostType)>[
    ('Texte', PostType.text),
    ('Photo', PostType.image),
    ('Vidéo', PostType.video),
    ('Carrousel', PostType.carousel),
  ]) {
    testWidgets('selects ${option.$1}', (tester) async {
      await _pumpScreen(tester);
      await tester.tap(find.text(option.$1));
      await tester.pump();

      expect(find.text('Sélectionné'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNotNull);
      expect(
        tester
            .widget<Semantics>(find.byKey(Key('post-type-${option.$2.name}')))
            .properties
            .selected,
        isTrue,
      );
    });
  }

  testWidgets('allows the user to change their selection', (tester) async {
    await _pumpScreen(tester);
    await tester.tap(find.text('Photo'));
    await tester.pump();
    await tester.tap(find.text('Vidéo'));
    await tester.pump();

    expect(
      tester
          .widget<Semantics>(find.byKey(const Key('post-type-image')))
          .properties
          .selected,
      isFalse,
    );
    expect(
      tester
          .widget<Semantics>(find.byKey(const Key('post-type-video')))
          .properties
          .selected,
      isTrue,
    );
    expect(find.text('Sélectionné'), findsOneWidget);
  });

  testWidgets('selected state is visible and not conveyed only by color', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.tap(find.text('Carrousel'));
    await tester.pump();

    expect(find.text('Sélectionné'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Carrousel.*Sélectionné')),
      findsOneWidget,
    );
  });

  testWidgets('Continue becomes actionable after selection', (tester) async {
    await _pumpScreen(tester);
    expect(_continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Texte'));
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('back returns to the previous Create Hub route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _NavigationHarness()));
    await tester.tap(find.text('Ouvrir le type de publication'));
    await tester.pumpAndSettle();
    expect(find.byType(PostTypeScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Create Hub origine'), findsOneWidget);
  });

  testWidgets('Continue opens the existing preparatory media route', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.tap(find.text('Photo'));
    await tester.pump();
    _continueButton(tester).onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Étape média préparatoire'), findsOneWidget);
  });

  testWidgets('transmits the typed selection to the next step', (tester) async {
    PostType? transmitted;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          screen: PostTypeScreen(onContinue: (value) => transmitted = value),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vidéo'));
    await tester.ensureVisible(find.byKey(const Key('post-type-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-type-continue')));
    await tester.pump();

    expect(transmitted, PostType.video);
    expect(container.read(composerControllerProvider).type, PostType.video);
  });

  testWidgets('supports a 320 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpScreen(tester, configureViewport: false);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a 390 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpScreen(tester, configureViewport: false);

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text and complete scrolling', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestApp(
          screen: PostTypeScreen(),
          textScaler: TextScaler.linear(1.3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('post-type-continue')),
      250,
      scrollable: find.byType(Scrollable),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Continuer'), findsOneWidget);
  });

  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    testWidgets('renders with ${mode.name} theme', (tester) async {
      await _pumpScreen(tester, themeMode: mode);

      final context = tester.element(find.byType(PostTypeScreen));
      expect(
        Theme.of(context).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses SafeArea through the secondary feature scaffold', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('exposes every choice and Continue semantically', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpScreen(tester);

    for (final label in ['Texte', 'Photo', 'Vidéo', 'Carrousel']) {
      expect(find.bySemanticsLabel(RegExp(label)), findsWidgets);
    }
    expect(find.bySemanticsLabel('Continuer'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('Create Hub still opens the publication type route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          routes: {AppRoutes.postType: (_) => const PostTypeScreen()},
          home: const CreateHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.byType(PostTypeScreen), findsOneWidget);
  });

  testWidgets('does not alter the exact five-destination AppShell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShell.testing(
          initialRoute: AppRoutes.create,
          pages: const [
            _Placeholder('Accueil'),
            CreateHubScreen(),
            _Placeholder('Calendrier'),
            _Placeholder('Statistiques'),
            _Placeholder('Profil'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(AppShell.destinations, hasLength(5));
    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Nouvelle publication'), findsOneWidget);
  });
}

FilledButton _continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('post-type-continue')),
        matching: find.byType(FilledButton),
      ),
    );

Future<void> _pumpScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  bool configureViewport = true,
}) async {
  if (configureViewport) await _setViewport(tester, const Size(390, 844));
  await tester.pumpWidget(
    ProviderScope(
      child: _TestApp(screen: const PostTypeScreen(), themeMode: themeMode),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.screen,
    this.themeMode = ThemeMode.light,
    this.textScaler = TextScaler.noScaling,
  });

  final Widget screen;
  final ThemeMode themeMode;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
      routes: {
        AppRoutes.postMedia:
            (_) => const _Placeholder('Étape média préparatoire'),
      },
      home: screen,
    );
  }
}

class _NavigationHarness extends StatelessWidget {
  const _NavigationHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      routes: {AppRoutes.postType: (_) => const PostTypeScreen()},
      home: Builder(
        builder:
            (context) => Scaffold(
              body: Column(
                children: [
                  const Text('Create Hub origine'),
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(context, AppRoutes.postType),
                    child: const Text('Ouvrir le type de publication'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}
