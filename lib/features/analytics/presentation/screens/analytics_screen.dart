import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/analytics_dashboard_content.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(analyticsControllerProvider);
    final controller = ref.read(analyticsControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: dashboard.when(
          loading:
              () => const AppLoader(
                key: Key('analytics-loading'),
                label: 'Chargement des statistiques',
              ),
          error:
              (error, stackTrace) => AppErrorState(
                key: const Key('analytics-error'),
                title: 'Les statistiques sont indisponibles',
                message:
                    'Impossible de charger vos performances pour le moment.',
                onRetry: controller.reload,
              ),
          data: (data) {
            if (data.isEmpty) {
              return AppEmptyState(
                key: const Key('analytics-empty'),
                title: 'Pas encore assez de données',
                message:
                    'Publiez du contenu pour commencer à mesurer vos performances.',
                icon: Icons.query_stats_outlined,
                actionLabel: 'Créer une publication',
                onAction:
                    () => Navigator.pushNamed(context, AppRoutes.postType),
              );
            }
            return AnalyticsDashboardContent(
              dashboard: data,
              onPeriodSelected: controller.selectPeriod,
              onTopContent:
                  () => Navigator.pushNamed(context, AppRoutes.postAnalytics),
              onCreate: () => Navigator.pushNamed(context, AppRoutes.postType),
            );
          },
        ),
      ),
    );
  }
}
