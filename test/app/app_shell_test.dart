import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  test('shell exposes exactly five destinations in product order', () {
    expect(AppShell.destinations, hasLength(5));
    expect(
      AppShell.destinations.map((destination) => destination.label),
      const ['Accueil', 'Créer', 'Calendrier', 'Statistiques', 'Profil'],
    );
  });

  final selections = <(String, int)>[
    ('Accueil', 0),
    ('Créer', 1),
    ('Calendrier', 2),
    ('Statistiques', 3),
    ('Profil', 4),
  ];

  for (final (label, index) in selections) {
    testWidgets('selects $label', (tester) async {
      await tester.pumpWidget(_buildShell());

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
        index,
      );
      expect(find.text('Destination $index'), findsOneWidget);
    });
  }

  testWidgets('initial route selects its matching destination', (tester) async {
    for (var index = 0; index < AppRoutes.mainRoutes.length; index++) {
      await tester.pumpWidget(
        _buildShell(initialRoute: AppRoutes.mainRouteForIndex(index)),
      );
      expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
        index,
      );
    }
  });

  testWidgets('IndexedStack preserves destination-local state', (tester) async {
    await tester.pumpWidget(
      _buildShell(
        pages: const [
          _CounterPage(),
          _TestPage(1),
          _TestPage(2),
          _TestPage(3),
          _TestPage(4),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('increment-counter')));
    await tester.pump();
    expect(find.text('Compteur 1'), findsOneWidget);

    await tester.tap(find.text('Créer'));
    await tester.pump();
    await tester.tap(find.text('Accueil'));
    await tester.pump();

    expect(find.text('Compteur 1'), findsOneWidget);
  });

  testWidgets('navigation exposes essential semantic labels', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_buildShell());

    for (final destination in AppShell.destinations) {
      expect(find.bySemanticsLabel(RegExp(destination.label)), findsWidgets);
    }
    semantics.dispose();
  });

  testWidgets('compact width and scaled text do not overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildShell(textScaleFactor: 1.3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shell supports light and dark themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildShell(themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byType(AppNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _buildShell({
  String initialRoute = AppRoutes.home,
  List<Widget>? pages,
  ThemeMode themeMode = ThemeMode.light,
  double textScaleFactor = 1,
}) {
  final testPages =
      pages ??
      const [
        _TestPage(0),
        _TestPage(1),
        _TestPage(2),
        _TestPage(3),
        _TestPage(4),
      ];
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
    home: AppShell.testing(initialRoute: initialRoute, pages: testPages),
  );
}

class _TestPage extends StatelessWidget {
  const _TestPage(this.index);

  final int index;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Destination $index'));
}

class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Compteur $count'),
          IconButton(
            key: const Key('increment-counter'),
            tooltip: 'Incrémenter',
            onPressed: () => setState(() => count++),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
