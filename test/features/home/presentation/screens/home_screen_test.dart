import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/home/data/repositories/mock_home_repository.dart';
import 'package:socialflow_ai/features/home/domain/entities/home_dashboard.dart';
import 'package:socialflow_ai/features/home/domain/repositories/home_repository.dart';
import 'package:socialflow_ai/features/home/presentation/controllers/home_controller.dart';
import 'package:socialflow_ai/features/home/presentation/screens/home_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  testWidgets('renders loading before repository data is available', (
    tester,
  ) async {
    final completer = Completer<HomeDashboard>();
    await tester.pumpWidget(_buildApp(_TestHomeRepository(completer.future)));

    expect(find.byKey(const Key('home-loading')), findsOneWidget);
    expect(find.text('Chargement du tableau de bord'), findsOneWidget);
  });

  testWidgets('renders the complete data dashboard', (tester) async {
    await _pumpDataDashboard(tester);

    expect(find.text('Bonjour, Sarah'), findsOneWidget);
    expect(find.text('Résumé des performances'), findsOneWidget);
    expect(find.text('Actions rapides'), findsOneWidget);
    expect(find.text('Publications à venir'), findsOneWidget);
    expect(find.text('Performance récente'), findsOneWidget);
    expect(find.text('Dernières publications'), findsOneWidget);
    expect(find.byKey(const Key('ai-suggestion')), findsOneWidget);
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('renders a useful empty state and its first action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(_TestHomeRepository(Future.value(const HomeDashboard.empty()))),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-empty')), findsOneWidget);
    expect(find.text('Aucune publication pour le moment'), findsOneWidget);
    expect(find.text('Créer ma première publication'), findsOneWidget);

    await tester.tap(find.text('Créer ma première publication'));
    await tester.pumpAndSettle();
    expect(find.text('Route création'), findsOneWidget);
  });

  testWidgets('renders an error state and retries the repository', (
    tester,
  ) async {
    final repository = _RetryHomeRepository();
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-error')), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    repository.shouldFail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour, Sarah'), findsOneWidget);
  });

  testWidgets('shows the active workspace and connected networks', (
    tester,
  ) async {
    await _pumpDataDashboard(tester);

    expect(find.byKey(const Key('active-workspace')), findsOneWidget);
    expect(find.text('Workspace actif'), findsOneWidget);
    expect(find.text('Social Flow AI'), findsOneWidget);
    expect(find.text('4 sur 4 réseaux opérationnels'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
  });

  testWidgets('shows the four synthetic metrics', (tester) async {
    await _pumpDataDashboard(tester);

    expect(find.text('124,8 K'), findsOneWidget);
    expect(find.text('8,4 %'), findsOneWidget);
    expect(find.text('+1 284'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('shows the four quick actions', (tester) async {
    await _pumpDataDashboard(tester);

    expect(find.text('Créer une publication'), findsOneWidget);
    expect(find.text('Assistant IA'), findsOneWidget);
    expect(find.text('Programmer'), findsOneWidget);
    expect(find.text('Ajouter un média'), findsOneWidget);
  });

  testWidgets('shows scheduled publication details and statuses', (
    tester,
  ) async {
    await _pumpDataDashboard(tester);

    expect(find.text('Aujourd’hui · 18:30 · Carrousel'), findsOneWidget);
    expect(find.text('Demain · 10:00 · Vidéo'), findsOneWidget);
    expect(find.text('Lundi · 08:15 · Texte'), findsOneWidget);
    expect(find.text('Programmé'), findsNWidgets(2));
    expect(find.text('À valider'), findsOneWidget);
  });

  testWidgets('shows recent publications and their useful metric', (
    tester,
  ) async {
    await _pumpDataDashboard(tester);

    expect(
      find.text('Notre méthode pour créer sans s’épuiser'),
      findsOneWidget,
    );
    expect(find.textContaining('42,8 K vues'), findsOneWidget);
    expect(find.textContaining('9,7 % engagement'), findsOneWidget);
  });

  testWidgets('shows the mock AI suggestion', (tester) async {
    await _pumpDataDashboard(tester);

    expect(find.text('Suggestion Social Flow AI'), findsOneWidget);
    expect(find.text('Votre meilleur créneau se confirme'), findsOneWidget);
    expect(find.text('Créer pour ce créneau'), findsOneWidget);
  });

  final actionRoutes = <String, String>{
    'Créer une publication': 'Route création',
    'Assistant IA': 'Route assistant',
    'Programmer': 'Route calendrier',
    'Ajouter un média': 'Route médias',
  };

  for (final entry in actionRoutes.entries) {
    testWidgets('${entry.key} uses the central route contract', (tester) async {
      await _pumpDataDashboard(tester);

      await tester.ensureVisible(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('notification, publication and AI interactions are available', (
    tester,
  ) async {
    await _pumpDataDashboard(tester);

    await tester.tap(find.byTooltip('Ouvrir les notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Route notifications'), findsOneWidget);

    Navigator.of(tester.element(find.text('Route notifications'))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('5 idées pour une semaine plus productive'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 idées pour une semaine plus productive'));
    await tester.pumpAndSettle();
    expect(find.text('Route publication programmée'), findsOneWidget);
  });

  testWidgets('supports a 320 px compact viewport without overflow', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 780));
    await _pumpDataDashboard(tester);

    await tester.drag(
      find.byKey(const Key('home-scroll')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _buildApp(_dataRepository, textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('home-scroll')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports light and dark themes', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildApp(_dataRepository, themeMode: mode));
      await tester.pumpAndSettle();

      expect(find.text('Résumé des performances'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes the dashboard and primary action semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpDataDashboard(tester);
    await tester.ensureVisible(find.text('Créer une publication'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Tableau de bord du workspace Social Flow AI'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Instagram, opérationnel')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('YouTube, opérationnel')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Créer une publication')),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('ai-suggestion')));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(
        RegExp('Suggestion IA, Votre meilleur créneau se confirme'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('remains embedded in the existing five-destination AppShell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(_dataRepository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.home,
            pages: const [
              HomeScreen(),
              _Placeholder('Créer'),
              _Placeholder('Calendrier'),
              _Placeholder('Statistiques'),
              _Placeholder('Profil'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(AppShell.destinations, hasLength(5));
    expect(find.text('Social Flow AI'), findsOneWidget);
  });
}

const _dataRepository = MockHomeRepository(delay: Duration.zero);

Future<void> _pumpDataDashboard(WidgetTester tester) async {
  await tester.pumpWidget(_buildApp(_dataRepository));
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildApp(
  HomeRepository repository, {
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
      routes: {
        AppRoutes.postType: (_) => const _Placeholder('Route création'),
        AppRoutes.aiAssistant: (_) => const _Placeholder('Route assistant'),
        AppRoutes.calendar: (_) => const _Placeholder('Route calendrier'),
        AppRoutes.mediaLibrary: (_) => const _Placeholder('Route médias'),
        AppRoutes.notifications:
            (_) => const _Placeholder('Route notifications'),
        AppRoutes.calendarDetail:
            (_) => const _Placeholder('Route publication programmée'),
        AppRoutes.postAnalytics:
            (_) => const _Placeholder('Route publication récente'),
      },
      home: const HomeScreen(),
    ),
  );
}

class _TestHomeRepository implements HomeRepository {
  const _TestHomeRepository(this.result);

  final Future<HomeDashboard> result;

  @override
  Future<HomeDashboard> fetchDashboard() => result;
}

class _RetryHomeRepository implements HomeRepository {
  bool shouldFail = true;

  @override
  Future<HomeDashboard> fetchDashboard() async {
    if (shouldFail) throw StateError('Mock dashboard failure');
    return MockHomeRepository.demoDashboard;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
