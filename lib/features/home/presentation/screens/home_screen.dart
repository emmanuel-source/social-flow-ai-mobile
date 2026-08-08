import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_dashboard_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: dashboard.when(
          loading:
              () => const AppLoader(
                key: Key('home-loading'),
                label: 'Chargement du tableau de bord',
              ),
          error:
              (error, stackTrace) => AppErrorState(
                key: const Key('home-error'),
                title: 'Le tableau de bord est indisponible',
                message:
                    'Impossible de charger vos informations pour le moment.',
                onRetry: ref.read(homeControllerProvider.notifier).reload,
              ),
          data:
              (data) => HomeDashboardContent(
                dashboard: data,
                onNotifications: () => _open(context, AppRoutes.notifications),
                onCreate: () => _open(context, AppRoutes.postType),
                onAiAssistant: () => _open(context, AppRoutes.aiAssistant),
                onSchedule: () => _open(context, AppRoutes.calendar),
                onMediaLibrary: () => _open(context, AppRoutes.mediaLibrary),
                onScheduledPost: () => _open(context, AppRoutes.calendarDetail),
                onRecentPost: () => _open(context, AppRoutes.postAnalytics),
              ),
        ),
      ),
    );
  }

  void _open(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
