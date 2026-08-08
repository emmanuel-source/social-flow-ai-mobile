import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_router.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';

void main() {
  test('initial navigation creates a single route', () {
    final routes = AppRouter.onGenerateInitialRoutes(AppRoutes.home);

    expect(routes, hasLength(1));
    expect(routes.single.settings.name, AppRoutes.home);
  });

  testWidgets('unknown route presents a controlled state and can return', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterHarness());

    await tester.tap(find.text('Ouvrir une route inconnue'));
    await tester.pumpAndSettle();

    expect(find.byType(UnknownRouteScreen), findsOneWidget);
    expect(find.text('Page introuvable'), findsOneWidget);
    expect(find.textContaining('/route/inconnue'), findsOneWidget);

    await tester.tap(find.text('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Racine de test'), findsOneWidget);
  });

  testWidgets('a main route replaces the previous navigator route', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [MainRouteObserver()],
        routes: {
          '/':
              (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                  child: const Text('Ouvrir Accueil'),
                ),
              ),
          AppRoutes.home:
              (context) => const Scaffold(body: Text('Accueil ouvert')),
        },
      ),
    );

    await tester.tap(find.text('Ouvrir Accueil'));
    await tester.pumpAndSettle();

    final homeContext = tester.element(find.text('Accueil ouvert'));
    expect(Navigator.canPop(homeContext), isFalse);
  });

  testWidgets('secondary route opens above the current route and returns', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterHarness());

    await tester.tap(find.text('Ouvrir les notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Racine de test'), findsOneWidget);
  });
}

Widget _buildRouterHarness() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    onGenerateRoute: AppRouter.onGenerateRoute,
    home: const _RouterTestRoot(),
  );
}

class _RouterTestRoot extends StatelessWidget {
  const _RouterTestRoot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Racine de test'),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/route/inconnue'),
            child: const Text('Ouvrir une route inconnue'),
          ),
          TextButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.notifications),
            child: const Text('Ouvrir les notifications'),
          ),
        ],
      ),
    );
  }
}
