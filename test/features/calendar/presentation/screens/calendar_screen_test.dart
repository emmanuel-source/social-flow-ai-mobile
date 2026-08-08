import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/calendar/data/repositories/mock_calendar_repository.dart';
import 'package:socialflow_ai/features/calendar/domain/entities/calendar_entry.dart';
import 'package:socialflow_ai/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:socialflow_ai/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:socialflow_ai/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  final now = DateTime(2026, 8, 8);
  late CalendarRepository repository;

  setUp(() {
    repository = _OfflineRepository(now);
  });

  testWidgets('renders loading before repository data is available', (
    tester,
  ) async {
    final completer = Completer<List<CalendarEntry>>();
    await tester.pumpWidget(_buildApp(_TestRepository(completer.future), now));

    expect(find.byKey(const Key('calendar-loading')), findsOneWidget);
    expect(find.text('Chargement du calendrier éditorial'), findsOneWidget);
  });

  testWidgets('renders the editorial calendar content', (tester) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.text('Calendrier éditorial'), findsOneWidget);
    expect(find.text('Août 2026'), findsOneWidget);
    expect(find.byKey(const Key('calendar-month-grid')), findsOneWidget);
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('does not expose a back button as an AppShell root', (
    tester,
  ) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('shows month week and list view controls', (tester) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.text('Mois'), findsOneWidget);
    expect(find.text('Semaine'), findsOneWidget);
    expect(find.text('Liste'), findsOneWidget);
  });

  testWidgets('moves to the next and previous month', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.byTooltip('Période suivante'));
    await tester.pump();
    expect(find.text('Septembre 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Période précédente'));
    await tester.pump();
    expect(find.text('Août 2026'), findsOneWidget);
  });

  testWidgets('today action restores the current date', (tester) async {
    await _pumpCalendar(tester, repository, now);
    await tester.tap(find.byTooltip('Période suivante'));
    await tester.pump();

    await tester.tap(find.text('Aujourd’hui'));
    await tester.pump();
    expect(find.text('Août 2026'), findsOneWidget);
    expect(find.text('Samedi 8 août'), findsOneWidget);
  });

  testWidgets('selecting a date updates the day section', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.byKey(const Key('calendar-day-2026-8-9')));
    await tester.pump();
    expect(find.text('Dimanche 9 août'), findsOneWidget);
    expect(find.text('Les coulisses du podcast #12'), findsOneWidget);
  });

  testWidgets('shows the count for multiple posts on one day', (tester) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('2 publications'), findsOneWidget);
  });

  testWidgets('shows platform time type summary and scheduled status', (
    tester,
  ) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.text('3 idées pour créer sans s’épuiser'), findsOneWidget);
    expect(find.text('Instagram · 18:30 · Reel'), findsOneWidget);
    expect(find.text('Programmé'), findsOneWidget);
    expect(
      find.text('Un Reel court avec trois conseils actionnables.'),
      findsOneWidget,
    );
  });

  testWidgets('shows draft content for the selected day', (tester) async {
    await _pumpCalendar(tester, repository, now);

    expect(find.text('Question à la communauté'), findsOneWidget);
    expect(find.text('Brouillon'), findsOneWidget);
  });

  testWidgets('opens the existing detail route from an entry', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.ensureVisible(find.text('3 idées pour créer sans s’épuiser'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 idées pour créer sans s’épuiser'));
    await tester.pumpAndSettle();
    expect(find.text('Route détail calendrier'), findsOneWidget);
  });

  testWidgets('opens central creation route from the header action', (
    tester,
  ) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.byTooltip('Ajouter une publication'));
    await tester.pumpAndSettle();
    expect(find.text('Route création'), findsOneWidget);
  });

  testWidgets('switches to a horizontally scrollable week view', (
    tester,
  ) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.text('Semaine'));
    await tester.pump();
    expect(find.byKey(const Key('calendar-week-strip')), findsOneWidget);
    expect(find.text('3–9 Août 2026'), findsOneWidget);
  });

  testWidgets('week controls move by seven days', (tester) async {
    await _pumpCalendar(tester, repository, now);
    await tester.tap(find.text('Semaine'));
    await tester.pump();

    await tester.tap(find.byTooltip('Période suivante'));
    await tester.pump();
    expect(find.text('10–16 Août 2026'), findsOneWidget);
  });

  testWidgets('list view groups entries for the current month', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.text('Liste'));
    await tester.pump();
    expect(find.byKey(const Key('calendar-list-view')), findsOneWidget);
    expect(find.text('Checklist du créateur efficace'), findsOneWidget);
  });

  testWidgets('list view exposes all semantic editorial statuses', (
    tester,
  ) async {
    await _pumpCalendar(tester, repository, now);
    await tester.tap(find.text('Liste'));
    await tester.pump();

    expect(find.text('Brouillon'), findsOneWidget);
    expect(find.text('Programmé'), findsNWidgets(2));
    expect(find.text('À valider'), findsOneWidget);
    expect(find.text('Publié'), findsOneWidget);
    expect(find.text('Échec'), findsOneWidget);
  });

  testWidgets('platform filter limits selected-day entries', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.widgetWithText(FilterChip, 'Facebook'));
    await tester.pump();
    expect(find.text('Question à la communauté'), findsOneWidget);
    expect(find.text('3 idées pour créer sans s’épuiser'), findsNothing);
  });

  testWidgets('all filter restores every selected-day entry', (tester) async {
    await _pumpCalendar(tester, repository, now);
    await tester.tap(find.widgetWithText(FilterChip, 'Facebook'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilterChip, 'Tous'));
    await tester.pump();
    expect(find.text('Question à la communauté'), findsOneWidget);
    expect(find.text('3 idées pour créer sans s’épuiser'), findsOneWidget);
  });

  testWidgets('empty selected day offers creation', (tester) async {
    await _pumpCalendar(tester, repository, now);

    await tester.tap(find.byKey(const Key('calendar-day-2026-8-2')));
    await tester.pump();
    expect(find.text('Aucune publication prévue'), findsOneWidget);
    expect(find.text('Ajouter une publication'), findsOneWidget);
  });

  testWidgets('empty repository still provides a useful first action', (
    tester,
  ) async {
    await _pumpCalendar(
      tester,
      MockCalendarRepository(now: now, delay: Duration.zero, entries: const []),
      now,
    );

    expect(find.text('Aucune publication prévue'), findsOneWidget);
    expect(find.text('Ajouter une publication'), findsOneWidget);
  });

  testWidgets('empty month list explains filters and period', (tester) async {
    await _pumpCalendar(tester, repository, now);
    await tester.tap(find.byTooltip('Période suivante'));
    await tester.pump();
    await tester.tap(find.text('Liste'));
    await tester.pump();

    expect(find.text('Aucune publication ce mois-ci'), findsOneWidget);
  });

  testWidgets('renders an error state and retries repository', (tester) async {
    final retryRepository = _RetryRepository();
    await tester.pumpWidget(_buildApp(retryRepository, now));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);

    retryRepository.shouldFail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Calendrier éditorial'), findsOneWidget);
  });

  testWidgets('supports a 320 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(320, 780));
    await _pumpCalendar(tester, repository, now);
    await tester.drag(
      find.byKey(const Key('calendar-scroll')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a 390 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpCalendar(tester, repository, now);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _buildApp(repository, now, textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('calendar-scroll')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports light and dark themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildApp(repository, now, themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.text('Calendrier éditorial'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes calendar date and entry semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpCalendar(tester, repository, now);

    expect(
      find.bySemanticsLabel('Calendrier éditorial Social Flow AI'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Samedi 8 août, 2 publications')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('Instagram, 3 idées pour créer sans s’épuiser'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('stays the third destination in the five-tab AppShell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarClockProvider.overrideWithValue(() => now),
          calendarRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.calendar,
            pages: const [
              _Placeholder('Accueil'),
              _Placeholder('Créer'),
              CalendarScreen(),
              _Placeholder('Statistiques'),
              _Placeholder('Profil'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(AppShell.destinations, hasLength(5));
    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Calendrier éditorial'), findsOneWidget);
  });

  testWidgets('preserves Home and Create AppShell destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarClockProvider.overrideWithValue(() => now),
          calendarRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.calendar,
            pages: const [
              _Placeholder('Écran Accueil'),
              _Placeholder('Hub Créer'),
              CalendarScreen(),
              _Placeholder('Statistiques'),
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
  });
}

Future<void> _pumpCalendar(
  WidgetTester tester,
  CalendarRepository repository,
  DateTime now,
) async {
  await tester.pumpWidget(_buildApp(repository, now));
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildApp(
  CalendarRepository repository,
  DateTime now, {
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  overrides: [
    calendarClockProvider.overrideWithValue(() => now),
    calendarRepositoryProvider.overrideWithValue(repository),
  ],
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
      AppRoutes.calendarDetail:
          (_) => const _Placeholder('Route détail calendrier'),
    },
    home: const CalendarScreen(),
  ),
);

class _TestRepository implements CalendarRepository {
  const _TestRepository(this.result);

  final Future<List<CalendarEntry>> result;

  @override
  Future<List<CalendarEntry>> fetchEntries() => result;
}

class _RetryRepository implements CalendarRepository {
  bool shouldFail = true;

  @override
  Future<List<CalendarEntry>> fetchEntries() async {
    if (shouldFail) throw StateError('Mock calendar failure');
    return _OfflineRepository(DateTime(2026, 8, 8)).fetchEntries();
  }
}

class _OfflineRepository implements CalendarRepository {
  _OfflineRepository(this.now);

  final DateTime now;

  @override
  Future<List<CalendarEntry>> fetchEntries() async {
    final entries =
        await MockCalendarRepository(
          now: now,
          delay: Duration.zero,
        ).fetchEntries();
    return [
      for (final entry in entries)
        CalendarEntry(
          id: entry.id,
          scheduledAt: entry.scheduledAt,
          timeZone: entry.timeZone,
          platform: entry.platform,
          contentType: entry.contentType,
          status: entry.status,
          title: entry.title,
          summary: entry.summary,
        ),
    ];
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
