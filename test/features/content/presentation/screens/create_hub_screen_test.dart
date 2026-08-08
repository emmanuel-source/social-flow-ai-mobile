import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/presentation/screens/create_hub_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  testWidgets('renders the initial Create Hub hierarchy', (tester) async {
    await _pumpHub(tester);

    expect(find.text('Créer'), findsOneWidget);
    expect(find.text('Que souhaitez-vous créer ?'), findsOneWidget);
    expect(find.text('Créer avec l’IA'), findsOneWidget);
    expect(find.text('Créer autrement'), findsOneWidget);
    expect(find.text('Reprendre'), findsOneWidget);
  });

  testWidgets('shows Nouvelle publication as the primary action', (
    tester,
  ) async {
    await _pumpHub(tester);

    expect(find.byKey(const Key('primary-create-action')), findsOneWidget);
    expect(find.text('Nouvelle publication'), findsOneWidget);
    expect(find.text('Action principale'), findsOneWidget);
    expect(find.byKey(const Key('new-publication-button')), findsOneWidget);
  });

  testWidgets('shows both AI entry points', (tester) async {
    await _pumpHub(tester);

    expect(find.text('Assistant IA'), findsOneWidget);
    expect(find.text('Générer des idées'), findsOneWidget);
  });

  testWidgets('shows media import and Media Library entries', (tester) async {
    await _pumpHub(tester);

    expect(find.text('Importer un média'), findsOneWidget);
    expect(find.text('Bibliothèque média'), findsOneWidget);
  });

  testWidgets('shows Video Studio, Campaign and Drafts entries', (
    tester,
  ) async {
    await _pumpHub(tester);

    expect(find.text('Transformer une vidéo'), findsOneWidget);
    expect(find.text('Créer une campagne'), findsOneWidget);
    expect(find.text('Brouillons'), findsOneWidget);
  });

  final routes = <String, String>{
    'Commencer': 'Route publication',
    'Assistant IA': 'Route assistant',
    'Générer des idées': 'Route assistant',
    'Importer un média': 'Route médias',
    'Bibliothèque média': 'Route médias',
    'Transformer une vidéo': 'Route vidéo',
    'Créer une campagne': 'Route campagne',
    'Brouillons': 'Route brouillons',
  };

  for (final entry in routes.entries) {
    testWidgets('${entry.key} uses a central route', (tester) async {
      await _pumpHub(tester);

      await tester.ensureVisible(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('future modules stay controlled route destinations', (
    tester,
  ) async {
    for (final label in [
      'Transformer une vidéo',
      'Créer une campagne',
      'Brouillons',
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _pumpHub(tester);
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(find.textContaining('Route '), findsOneWidget);
    }
  });

  testWidgets('does not add a sixth top-level destination', (tester) async {
    expect(AppRoutes.mainRoutes, hasLength(5));
    expect(AppShell.destinations, hasLength(5));
  });

  testWidgets('does not show a parasitic back button', (tester) async {
    await _pumpHub(tester);

    expect(find.byType(BackButton), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byTooltip('Retour'), findsNothing);
  });

  testWidgets('supports a 320 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(320, 780));
    await _pumpHub(tester);

    await tester.drag(
      find.byKey(const Key('create-hub-scroll')),
      const Offset(0, -2600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a 390 px viewport and complete scroll', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpHub(tester);

    await tester.ensureVisible(find.text('Brouillons'));
    await tester.pumpAndSettle();
    expect(find.text('Brouillons'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _buildApp(textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('create-hub-scroll')),
      const Offset(0, -2600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports Light and Dark Theme at 390 px', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildApp(themeMode: mode));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle publication'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes logical primary semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpHub(tester);

    expect(
      find.bySemanticsLabel(RegExp('Centre de création Social Flow AI')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Nouvelle publication, action principale'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('Assistant IA.*Construire un contenu guidé'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('remains the second destination of the existing AppShell', (
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

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
    expect(find.text('Nouvelle publication'), findsOneWidget);
  });
}

Future<void> _pumpHub(WidgetTester tester) async {
  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildApp({
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) {
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
      AppRoutes.postType: (_) => const _Placeholder('Route publication'),
      AppRoutes.aiAssistant: (_) => const _Placeholder('Route assistant'),
      AppRoutes.mediaLibrary: (_) => const _Placeholder('Route médias'),
      AppRoutes.videoSource: (_) => const _Placeholder('Route vidéo'),
      AppRoutes.campaign: (_) => const _Placeholder('Route campagne'),
      AppRoutes.drafts: (_) => const _Placeholder('Route brouillons'),
    },
    home: const CreateHubScreen(),
  );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
