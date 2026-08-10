import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/analytics/data/repositories/mock_analytics_repository.dart';
import 'package:socialflow_ai/features/analytics/domain/entities/analytics_dashboard.dart';
import 'package:socialflow_ai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:socialflow_ai/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:socialflow_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  late AnalyticsRepository repository;

  setUp(() {
    repository = MockAnalyticsRepository(delay: Duration.zero);
  });

  testWidgets('renders loading before repository data is available', (
    tester,
  ) async {
    final completer = Completer<AnalyticsDashboard>();
    await tester.pumpWidget(_buildApp(_TestRepository(completer.future)));

    expect(find.byKey(const Key('analytics-loading')), findsOneWidget);
    expect(find.text('Chargement des statistiques'), findsOneWidget);
  });

  testWidgets('renders the initial 30 day analytics dashboard', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.text('Statistiques'), findsOneWidget);
    expect(find.text('Social Flow AI'), findsOneWidget);
    expect(find.text('Données démo'), findsOneWidget);
    expect(find.text('124,8 K'), findsWidgets);
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('does not expose a back button on the AppShell root', (
    tester,
  ) async {
    await _pumpDashboard(tester, repository);

    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('offers 7 30 and 90 day periods', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.text('7 jours'), findsOneWidget);
    expect(find.text('30 jours'), findsOneWidget);
    expect(find.text('90 jours'), findsOneWidget);
  });

  testWidgets('selecting 7 days updates all primary metrics', (tester) async {
    await _pumpDashboard(tester, repository);

    await tester.tap(find.widgetWithText(FilterChip, '7 jours'));
    await tester.pumpAndSettle();
    expect(find.text('32,4 K'), findsWidgets);
    expect(find.text('8,9 %'), findsOneWidget);
    expect(find.text('+346'), findsOneWidget);
    expect(find.text('4,7 K'), findsOneWidget);
  });

  testWidgets('selecting 90 days updates dashboard content', (tester) async {
    await _pumpDashboard(tester, repository);

    await tester.tap(find.widgetWithText(FilterChip, '90 jours'));
    await tester.pumpAndSettle();
    expect(find.text('368,2 K'), findsWidgets);
    expect(find.text('Une croissance durable'), findsOneWidget);
    expect(
      find.text('Le guide complet de la stratégie sociale'),
      findsOneWidget,
    );
  });

  testWidgets('period changes replace chart and platform data', (tester) async {
    await _pumpDashboard(tester, repository);
    expect(find.text('48,7 K vues · 10,1 % engagement'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, '7 jours'));
    await tester.pumpAndSettle();
    expect(find.text('13,8 K vues · 10,2 % engagement'), findsOneWidget);
    expect(find.text('48,7 K vues · 10,1 % engagement'), findsNothing);
  });

  testWidgets('shows four decision-focused KPI cards', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.text('Vues'), findsOneWidget);
    expect(find.text('Engagement'), findsOneWidget);
    expect(find.text('Nouveaux abonnés'), findsOneWidget);
    expect(find.text('Interactions'), findsOneWidget);
    expect(find.text('Comparaison avec la période précédente'), findsOneWidget);
  });

  testWidgets('communicates positive and negative trends with text', (
    tester,
  ) async {
    await _pumpDashboard(tester, repository);
    await tester.tap(find.widgetWithText(FilterChip, '7 jours'));
    await tester.pumpAndSettle();

    expect(find.text('+9,8 %'), findsNWidgets(2));
    expect(find.text('-2,4 %'), findsOneWidget);
  });

  testWidgets('renders a single useful fl_chart visualization', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byKey(const Key('analytics-views-chart')), findsOneWidget);
    expect(find.text('Évolution des vues'), findsOneWidget);
  });

  testWidgets('chart is backed by the selected period time series', (
    tester,
  ) async {
    await _pumpDashboard(tester, repository);
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.single.spots, hasLength(15));

    await tester.tap(find.widgetWithText(FilterChip, '7 jours'));
    await tester.pumpAndSettle();
    final updatedChart = tester.widget<LineChart>(find.byType(LineChart));
    expect(updatedChart.data.lineBarsData.single.spots, hasLength(7));
  });

  testWidgets('shows concise performance by platform', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.text('Performance par plateforme'), findsOneWidget);
    expect(find.text('Instagram'), findsWidgets);
    expect(find.text('TikTok'), findsWidgets);
    expect(find.text('YouTube'), findsWidgets);
    expect(find.text('Facebook'), findsOneWidget);
  });

  testWidgets('shows ranked top contents with useful metrics', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.text('Meilleurs contenus'), findsOneWidget);
    expect(
      find.text('Notre méthode pour créer sans s’épuiser'),
      findsOneWidget,
    );
    expect(find.text('Top 1'), findsOneWidget);
    expect(find.textContaining('42,8 K vues'), findsOneWidget);
  });

  testWidgets('shows the mock decision-oriented insight', (tester) async {
    await _pumpDashboard(tester, repository);

    expect(find.byKey(const Key('analytics-insight')), findsOneWidget);
    expect(find.text('Insight Social Flow AI'), findsOneWidget);
    expect(find.text('Votre meilleur créneau se confirme'), findsOneWidget);
  });

  testWidgets('top content opens the existing central detail route', (
    tester,
  ) async {
    await _pumpDashboard(tester, repository);
    await tester.ensureVisible(
      find.text('Notre méthode pour créer sans s’épuiser'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notre méthode pour créer sans s’épuiser'));
    await tester.pumpAndSettle();
    expect(find.text('Route détail publication'), findsOneWidget);
  });

  testWidgets('insight action opens the central creation route', (
    tester,
  ) async {
    await _pumpDashboard(tester, repository);
    await tester.ensureVisible(find.text('Créer un contenu similaire'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Créer un contenu similaire'));
    await tester.pumpAndSettle();
    expect(find.text('Route création'), findsOneWidget);
  });

  testWidgets('renders a useful empty state and creation action', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      MockAnalyticsRepository(delay: Duration.zero, dashboards: const {}),
    );

    expect(find.byKey(const Key('analytics-empty')), findsOneWidget);
    expect(find.text('Pas encore assez de données'), findsOneWidget);
    await tester.tap(find.text('Créer une publication'));
    await tester.pumpAndSettle();
    expect(find.text('Route création'), findsOneWidget);
  });

  testWidgets('renders an error state and retries', (tester) async {
    final retryRepository = _RetryRepository();
    await tester.pumpWidget(_buildApp(retryRepository));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('analytics-error')), findsOneWidget);

    retryRepository.shouldFail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('124,8 K'), findsWidgets);
  });

  testWidgets('supports a 320 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(320, 780));
    await _pumpDashboard(tester, repository);
    await tester.drag(
      find.byKey(const Key('analytics-scroll')),
      const Offset(0, -2500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a 390 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpDashboard(tester, repository);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text and long values', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _buildApp(repository, textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('analytics-scroll')),
      const Offset(0, -2500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports light and dark themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildApp(repository, themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes KPI chart platform and content semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpDashboard(tester, repository);

    expect(
      find.bySemanticsLabel(
        'Statistiques du workspace Social Flow AI, 30 derniers jours',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Vues, 124,8 K, évolution')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Graphique des vues, hausse')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Instagram, 48,7 K vues')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('stays fourth in the exact five-destination AppShell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [analyticsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.analytics,
            pages: const [
              _Placeholder('Accueil'),
              _Placeholder('Créer'),
              _Placeholder('Calendrier'),
              AnalyticsScreen(),
              _Placeholder('Profil'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(AppShell.destinations, hasLength(5));
    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Statistiques'), findsWidgets);
  });

  testWidgets('preserves Home Create and Calendar destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [analyticsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.analytics,
            pages: const [
              _Placeholder('Écran Accueil'),
              _Placeholder('Hub Créer'),
              _Placeholder('Calendrier éditorial'),
              AnalyticsScreen(),
              _Placeholder('Profil'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accueil'));
    await tester.pump();
    expect(find.text('Écran Accueil'), findsOneWidget);
    await tester.tap(find.text('Créer'));
    await tester.pump();
    expect(find.text('Hub Créer'), findsOneWidget);
    await tester.tap(find.text('Calendrier'));
    await tester.pump();
    expect(find.text('Calendrier éditorial'), findsOneWidget);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  AnalyticsRepository repository,
) async {
  await tester.pumpWidget(_buildApp(repository));
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildApp(
  AnalyticsRepository repository, {
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  overrides: [analyticsRepositoryProvider.overrideWithValue(repository)],
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
      AppRoutes.postAnalytics:
          (_) => const _Placeholder('Route détail publication'),
    },
    home: const AnalyticsScreen(),
  ),
);

class _TestRepository implements AnalyticsRepository {
  const _TestRepository(this.result);

  final Future<AnalyticsDashboard> result;

  @override
  Future<AnalyticsDashboard> fetchDashboard(AnalyticsPeriod period) => result;
}

class _RetryRepository implements AnalyticsRepository {
  bool shouldFail = true;

  @override
  Future<AnalyticsDashboard> fetchDashboard(AnalyticsPeriod period) async {
    if (shouldFail) throw StateError('Mock analytics failure');
    return MockAnalyticsRepository(delay: Duration.zero).fetchDashboard(period);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
