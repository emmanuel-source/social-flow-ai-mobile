import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/content/presentation/screens/create_hub_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../shared/widgets/app_navigation_bar.dart';
import 'app_routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.initialRoute, super.key}) : pages = null;

  const AppShell.testing({
    required this.initialRoute,
    required List<Widget> pages,
    super.key,
  }) : pages = pages,
       assert(pages.length == AppRoutes.mainRoutes.length);

  final String initialRoute;
  final List<Widget>? pages;

  static const destinations = <AppNavigationDestination>[
    AppNavigationDestination(
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppNavigationDestination(
      label: 'Créer',
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box,
    ),
    AppNavigationDestination(
      label: 'Calendrier',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    AppNavigationDestination(
      label: 'Statistiques',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
    ),
    AppNavigationDestination(
      label: 'Profil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = _indexForRoute(widget.initialRoute);

  List<Widget> get _defaultPages => <Widget>[
    const HomeScreen(),
    const CreateHubScreen(),
    const CalendarScreen(),
    const AnalyticsScreen(),
    ProfileScreen(onLogout: _logout),
  ];

  Future<void> _logout() async {
    await ProviderScope.containerOf(
      context,
    ).read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  static int _indexForRoute(String route) {
    final index = AppRoutes.mainIndexForRoute(route);
    assert(index != null, 'AppShell requires a main navigation route.');
    return index ?? 0;
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute) {
      _index = _indexForRoute(widget.initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages ?? _defaultPages;
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: AppShell.destinations,
      ),
    );
  }
}
