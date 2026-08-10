import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/auth/domain/entities/user_session.dart';
import 'package:socialflow_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:socialflow_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:socialflow_ai/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:socialflow_ai/features/profile/domain/entities/profile_overview.dart';
import 'package:socialflow_ai/features/profile/domain/repositories/profile_repository.dart';
import 'package:socialflow_ai/features/profile/presentation/controllers/profile_controller.dart';
import 'package:socialflow_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_navigation_bar.dart';

void main() {
  late ProfileRepository repository;

  setUp(() {
    repository = const MockProfileRepository(delay: Duration.zero);
  });

  testWidgets('renders loading before repository data is available', (
    tester,
  ) async {
    final completer = Completer<ProfileOverview>();
    await tester.pumpWidget(_buildApp(_TestRepository(completer.future)));

    expect(find.byKey(const Key('profile-loading')), findsOneWidget);
    expect(find.text('Chargement du profil'), findsOneWidget);
  });

  testWidgets('renders the personal control centre', (tester) async {
    await _pumpProfile(tester, repository);

    expect(find.text('Profil'), findsOneWidget);
    expect(
      find.text('Votre centre de contrôle personnel et organisationnel.'),
      findsOneWidget,
    );
    expect(find.text('Données démo'), findsOneWidget);
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('renders the mock identity and plan', (tester) async {
    await _pumpProfile(tester, repository);

    expect(find.text('Rami'), findsWidgets);
    expect(find.text('rami@socialflow.ai'), findsOneWidget);
    expect(find.text('Plan Pro'), findsWidgets);
  });

  testWidgets('renders active workspace ownership and members', (tester) async {
    await _pumpProfile(tester, repository);

    expect(find.text('Workspace actif'), findsOneWidget);
    expect(find.text('Social Flow AI'), findsOneWidget);
    expect(find.text('Owner · 4 membres'), findsOneWidget);
  });

  testWidgets('summarises social account connectivity', (tester) async {
    await _pumpProfile(tester, repository);

    expect(find.text('3 sur 4 connectés'), findsOneWidget);
    expect(find.text('Instagram · Connecté'), findsOneWidget);
    expect(find.text('Facebook · Connecté'), findsOneWidget);
    expect(find.text('TikTok · Connecté'), findsOneWidget);
    expect(find.text('YouTube · Non connecté'), findsOneWidget);
  });

  testWidgets('separates organization from account preferences', (
    tester,
  ) async {
    await _pumpProfile(tester, repository);

    expect(find.text('Organisation'), findsOneWidget);
    await _scrollTo(tester, 'Compte et préférences');
    expect(find.text('Compte et préférences'), findsOneWidget);
  });

  for (final item in <String>[
    'Brand Kit',
    'Équipe et permissions',
    'Validations',
    'Agents et automatisations',
  ]) {
    testWidgets('shows organization entry $item', (tester) async {
      await _pumpProfile(tester, repository);
      await _scrollTo(tester, item);

      expect(find.text(item), findsOneWidget);
    });
  }

  for (final item in <String>[
    'Abonnement',
    'Notifications',
    'Sécurité',
    'Paramètres',
  ]) {
    testWidgets('shows account entry $item', (tester) async {
      await _pumpProfile(tester, repository);
      await _scrollTo(tester, item);

      expect(find.text(item), findsOneWidget);
    });
  }

  final routeCases = <(String, String)>[
    ('Social Flow AI', AppRoutes.workspaces),
    ('Gérer', AppRoutes.accounts),
    ('Brand Kit', AppRoutes.brandKit),
    ('Équipe et permissions', AppRoutes.team),
    ('Validations', AppRoutes.approvals),
    ('Agents et automatisations', AppRoutes.agents),
    ('Abonnement', AppRoutes.subscription),
    ('Notifications', AppRoutes.notifications),
    ('Sécurité', AppRoutes.security),
    ('Paramètres', AppRoutes.settings),
  ];
  for (final (label, route) in routeCases) {
    testWidgets('$label opens its existing central route', (tester) async {
      await _pumpProfile(tester, repository);
      await _scrollTo(tester, label);
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();

      expect(find.text('Destination $route'), findsOneWidget);
    });
  }

  testWidgets('logout requires confirmation and cancel preserves session', (
    tester,
  ) async {
    var logoutCalls = 0;
    await _pumpProfile(tester, repository, onLogout: () async => logoutCalls++);
    await _scrollTo(tester, 'Se déconnecter');
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Se déconnecter ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(logoutCalls, 0);
  });

  testWidgets('confirmed logout delegates to application orchestration', (
    tester,
  ) async {
    var logoutCalls = 0;
    await _pumpProfile(tester, repository, onLogout: () async => logoutCalls++);
    await _scrollTo(tester, 'Se déconnecter');
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
    await tester.pumpAndSettle();

    expect(logoutCalls, 1);
  });

  testWidgets(
    'AppShell logout clears the mocked auth session and opens login',
    (tester) async {
      final authRepository = _TrackingAuthRepository();
      final navigatorObserver = _RecordingNavigatorObserver();
      await _setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
            authRepositoryProvider.overrideWithValue(authRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            navigatorObservers: [navigatorObserver],
            routes: {
              AppRoutes.login:
                  (_) => const _Placeholder('Destination connexion'),
            },
            home: const AppShell(initialRoute: AppRoutes.profile),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.dragUntilVisible(
        find.text('Se déconnecter').last,
        find.descendant(
          of: find.byKey(const Key('profile-scroll')),
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -300),
      );
      await tester.tap(find.byKey(const Key('profile-logout')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
      await tester.pump(const Duration(seconds: 1));

      expect(authRepository.logoutCalls, 1);
      expect(navigatorObserver.pushedNames, contains(AppRoutes.login));
    },
  );

  testWidgets('renders an error state and retries successfully', (
    tester,
  ) async {
    final retryRepository = _RetryRepository();
    await tester.pumpWidget(_buildApp(retryRepository));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-error')), findsOneWidget);

    retryRepository.shouldFail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('rami@socialflow.ai'), findsOneWidget);
  });

  testWidgets('does not expose a back button on the AppShell root', (
    tester,
  ) async {
    await _pumpProfile(tester, repository);

    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('supports a 320 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(320, 780));
    await _pumpProfile(tester, repository, configureViewport: false);
    await tester.drag(
      find.byKey(const Key('profile-scroll')),
      const Offset(0, -1800),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a 390 px viewport without overflow', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpProfile(tester, repository, configureViewport: false);

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports enlarged text and long mock values', (tester) async {
    await _setViewport(tester, const Size(320, 844));
    await tester.pumpWidget(
      _buildApp(
        const MockProfileRepository(
          delay: Duration.zero,
          overview: _longOverview,
        ),
        textScaler: const TextScaler.linear(1.3),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('profile-scroll')),
      const Offset(0, -2200),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports light and dark themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_buildApp(repository, themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.text('rami@socialflow.ai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes identity workspace and logout semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpProfile(tester, repository);

    expect(
      find.bySemanticsLabel(RegExp('Profil de Rami, rami@socialflow.ai')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('Workspace Social Flow AI, rôle Owner, 4 membres'),
      ),
      findsOneWidget,
    );
    await _scrollTo(tester, 'Se déconnecter');
    expect(find.bySemanticsLabel('Se déconnecter'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('stays fifth in the exact five-destination AppShell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.profile,
            pages: [
              const _Placeholder('Écran Accueil'),
              const _Placeholder('Hub Créer'),
              const _Placeholder('Calendrier éditorial'),
              const _Placeholder('Statistiques'),
              ProfileScreen(onLogout: () async {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(AppShell.destinations, hasLength(5));
    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('rami@socialflow.ai'), findsOneWidget);
  });

  testWidgets('preserves the four previously completed destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: AppShell.testing(
            initialRoute: AppRoutes.profile,
            pages: [
              const _Placeholder('Écran Accueil'),
              const _Placeholder('Hub Créer'),
              const _Placeholder('Calendrier éditorial'),
              const _Placeholder('Écran Statistiques'),
              ProfileScreen(onLogout: () async {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final destination in <(String, String)>[
      ('Accueil', 'Écran Accueil'),
      ('Créer', 'Hub Créer'),
      ('Calendrier', 'Calendrier éditorial'),
      ('Statistiques', 'Écran Statistiques'),
    ]) {
      await tester.tap(find.text(destination.$1));
      await tester.pump();
      expect(find.text(destination.$2), findsOneWidget);
    }
  });
}

const _longOverview = ProfileOverview(
  identity: ProfileIdentity(
    name: 'Rami avec un nom particulièrement long pour la validation',
    email: 'rami.avec.une.adresse.tres.longue@socialflow.example.com',
    planName: 'Professionnel avancé',
  ),
  workspace: ProfileWorkspaceSummary(
    name: 'Social Flow AI — Workspace international très long',
    role: 'Administrateur principal',
    membersCount: 128,
  ),
  socialAccounts: [],
);

Future<void> _pumpProfile(
  WidgetTester tester,
  ProfileRepository repository, {
  Future<void> Function()? onLogout,
  bool configureViewport = true,
}) async {
  if (configureViewport) {
    await _setViewport(tester, const Size(390, 844));
  }
  await tester.pumpWidget(_buildApp(repository, onLogout: onLogout));
  await tester.pumpAndSettle();
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _scrollTo(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label).last,
    240,
    scrollable: find.descendant(
      of: find.byKey(const Key('profile-scroll')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _buildApp(
  ProfileRepository repository, {
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  Future<void> Function()? onLogout,
}) => ProviderScope(
  overrides: [profileRepositoryProvider.overrideWithValue(repository)],
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
      for (final route in <String>[
        AppRoutes.workspaces,
        AppRoutes.accounts,
        AppRoutes.brandKit,
        AppRoutes.team,
        AppRoutes.approvals,
        AppRoutes.agents,
        AppRoutes.subscription,
        AppRoutes.notifications,
        AppRoutes.security,
        AppRoutes.settings,
      ])
        route: (_) => _Placeholder('Destination $route'),
    },
    home: ProfileScreen(onLogout: onLogout ?? () async {}),
  ),
);

class _TestRepository implements ProfileRepository {
  const _TestRepository(this.result);

  final Future<ProfileOverview> result;

  @override
  Future<ProfileOverview> fetchOverview() => result;
}

class _RetryRepository implements ProfileRepository {
  bool shouldFail = true;

  @override
  Future<ProfileOverview> fetchOverview() async {
    if (shouldFail) throw StateError('Mock profile failure');
    return MockProfileRepository.demoOverview;
  }
}

class _TrackingAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<UserSession?> currentSession() async => const UserSession(
    userId: 'rami',
    name: 'Rami',
    email: 'rami@socialflow.ai',
    accessToken: 'mock-session',
  );

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final pushedNames = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedNames.add(route.settings.name);
    super.didPush(route, previousRoute);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}
