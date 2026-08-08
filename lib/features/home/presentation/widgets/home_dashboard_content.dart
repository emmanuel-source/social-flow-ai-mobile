import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/home_dashboard.dart';

class HomeDashboardContent extends StatelessWidget {
  const HomeDashboardContent({
    required this.dashboard,
    required this.onNotifications,
    required this.onCreate,
    required this.onAiAssistant,
    required this.onSchedule,
    required this.onMediaLibrary,
    required this.onScheduledPost,
    required this.onRecentPost,
    super.key,
  });

  final HomeDashboard dashboard;
  final VoidCallback onNotifications;
  final VoidCallback onCreate;
  final VoidCallback onAiAssistant;
  final VoidCallback onSchedule;
  final VoidCallback onMediaLibrary;
  final VoidCallback onScheduledPost;
  final VoidCallback onRecentPost;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Tableau de bord du workspace ${dashboard.workspace.name}',
      child: ListView(
        key: const Key('home-scroll'),
        padding: AppSpacing.screenInsets,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    userName: dashboard.userName,
                    workspace: dashboard.workspace,
                    networks: dashboard.networks,
                    isDemo: dashboard.isDemo,
                    onNotifications: onNotifications,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  if (dashboard.isEmpty)
                    AppEmptyState(
                      key: const Key('home-empty'),
                      title: 'Aucune publication pour le moment',
                      message:
                          'Créez votre première publication pour commencer à suivre votre activité ici.',
                      icon: Icons.rocket_launch_outlined,
                      actionLabel: 'Créer ma première publication',
                      onAction: onCreate,
                    )
                  else ...[
                    _PerformanceSummary(metrics: dashboard.metrics),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _QuickActions(
                      onCreate: onCreate,
                      onAiAssistant: onAiAssistant,
                      onSchedule: onSchedule,
                      onMediaLibrary: onMediaLibrary,
                    ),
                    if (dashboard.scheduledPosts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _ScheduledPosts(
                        posts: dashboard.scheduledPosts,
                        onViewAll: onSchedule,
                        onPost: onScheduledPost,
                      ),
                    ],
                    if (dashboard.performanceTrend case final trend?) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _PerformanceTrendCard(trend: trend),
                    ],
                    if (dashboard.recentPosts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _RecentPosts(
                        posts: dashboard.recentPosts,
                        onPost: onRecentPost,
                      ),
                    ],
                    if (dashboard.aiSuggestion case final suggestion?) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _AiSuggestionCard(
                        suggestion: suggestion,
                        onAction: onAiAssistant,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.workspace,
    required this.networks,
    required this.isDemo,
    required this.onNotifications,
  });

  final String userName;
  final HomeWorkspaceSummary workspace;
  final List<HomeNetworkSummary> networks;
  final bool isDemo;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final connected = networks.where((network) => network.connected).length;
    final allConnected = networks.isNotEmpty && connected == networks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, $userName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Voici l’essentiel de votre activité.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppIconButton(
              icon: Icons.notifications_none,
              tooltip: 'Ouvrir les notifications',
              onPressed: onNotifications,
            ),
            const SizedBox(width: AppSpacing.xs),
            AppAvatar(label: userName),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          key: const Key('active-workspace'),
          elevated: true,
          semanticLabel: 'Workspace actif, ${workspace.name}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: const Icon(Icons.business_outlined),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workspace actif',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          workspace.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  if (isDemo)
                    const AppBadge(label: 'Démo', tone: AppBadgeTone.info),
                ],
              ),
              if (networks.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Icon(
                      allConnected
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      size: AppSizes.iconMedium,
                      color:
                          allConnected ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '$connected sur ${networks.length} réseaux opérationnels',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final network in networks)
                      AppBadge(
                        label: network.platform.label,
                        icon:
                            network.connected
                                ? Icons.check
                                : Icons.priority_high,
                        tone:
                            network.connected
                                ? AppBadgeTone.success
                                : AppBadgeTone.warning,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PerformanceSummary extends StatelessWidget {
  const _PerformanceSummary({required this.metrics});

  final List<HomeMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final rows = <List<HomeMetric>>[];
    for (var index = 0; index < metrics.length; index += 2) {
      final end = index + 2 < metrics.length ? index + 2 : metrics.length;
      rows.add(metrics.sublist(index, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Résumé des performances',
          subtitle: 'Aperçu synthétique des 30 derniers jours',
        ),
        const SizedBox(height: AppSpacing.md),
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          Row(
            children: [
              for (var index = 0; index < rows[rowIndex].length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                MetricCard(
                  label: rows[rowIndex][index].label,
                  value: rows[rowIndex][index].value,
                  trend: rows[rowIndex][index].trend,
                ),
              ],
              if (rows[rowIndex].length == 1) const Expanded(child: SizedBox()),
            ],
          ),
          if (rowIndex < rows.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCreate,
    required this.onAiAssistant,
    required this.onSchedule,
    required this.onMediaLibrary,
  });

  final VoidCallback onCreate;
  final VoidCallback onAiAssistant;
  final VoidCallback onSchedule;
  final VoidCallback onMediaLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Actions rapides',
          subtitle: 'Passez directement à votre prochaine tâche',
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = AppBreakpoints.isCompact(constraints.maxWidth);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              mainAxisExtent: compact ? 204 : 172,
              children: [
                ActionTile(
                  icon: Icons.add_box_outlined,
                  title: 'Créer une publication',
                  subtitle: 'Composer pour vos réseaux',
                  onTap: onCreate,
                ),
                ActionTile(
                  icon: Icons.auto_awesome,
                  title: 'Assistant IA',
                  subtitle: 'Trouver la prochaine idée',
                  onTap: onAiAssistant,
                ),
                ActionTile(
                  icon: Icons.event_outlined,
                  title: 'Programmer',
                  subtitle: 'Voir votre planning',
                  onTap: onSchedule,
                ),
                ActionTile(
                  icon: Icons.perm_media_outlined,
                  title: 'Ajouter un média',
                  subtitle: 'Ouvrir la médiathèque',
                  onTap: onMediaLibrary,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ScheduledPosts extends StatelessWidget {
  const _ScheduledPosts({
    required this.posts,
    required this.onViewAll,
    required this.onPost,
  });

  final List<HomeScheduledPost> posts;
  final VoidCallback onViewAll;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final useStackedHeader =
                constraints.maxWidth < AppBreakpoints.medium ||
                MediaQuery.textScalerOf(context).scale(1) > 1.1;
            if (!useStackedHeader) {
              return SectionHeader(
                title: 'Publications à venir',
                subtitle: 'Vos trois prochaines échéances',
                actionLabel: 'Voir le calendrier',
                onAction: onViewAll,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Publications à venir',
                  subtitle: 'Vos trois prochaines échéances',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTertiaryButton(
                  label: 'Voir le calendrier',
                  icon: Icons.arrow_forward,
                  onPressed: onViewAll,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (var index = 0; index < posts.length; index++) ...[
                AppListTile(
                  title: posts[index].title,
                  subtitle:
                      '${posts[index].scheduleLabel} · ${posts[index].contentType}',
                  leading: AppAvatar(
                    label: posts[index].platform.label,
                    size: AppAvatarSize.small,
                  ),
                  trailing: _PublicationStatusBadge(
                    status: posts[index].status,
                  ),
                  onTap: onPost,
                ),
                if (index < posts.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PerformanceTrendCard extends StatelessWidget {
  const _PerformanceTrendCard({required this.trend});

  final HomePerformanceTrend trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var index = 0; index < trend.points.length; index++)
        FlSpot(index.toDouble(), trend.points[index]),
    ];
    final minY = trend.points.reduce((a, b) => a < b ? a : b) * 0.8;
    final maxY = trend.points.reduce((a, b) => a > b ? a : b) * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Performance récente',
          subtitle: 'Une tendance utile, sans remplacer vos statistiques',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          semanticLabel: '${trend.label}, évolution ${trend.change}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trend.label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  AppBadge(
                    label: trend.change,
                    tone: AppBadgeTone.success,
                    icon: Icons.trending_up,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 112,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: scheme.primary,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: scheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentPosts extends StatelessWidget {
  const _RecentPosts({required this.posts, required this.onPost});

  final List<HomeRecentPost> posts;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Dernières publications',
          subtitle: 'Un aperçu de vos contenus récemment publiés',
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (var index = 0; index < posts.length; index++) ...[
                AppListTile(
                  title: posts[index].title,
                  subtitle:
                      '${posts[index].preview} · ${posts[index].primaryMetric}',
                  leading: AppAvatar(
                    label: posts[index].platform.label,
                    size: AppAvatarSize.small,
                  ),
                  trailing: _PublicationStatusBadge(
                    status: posts[index].status,
                  ),
                  onTap: onPost,
                ),
                if (index < posts.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard({required this.suggestion, required this.onAction});

  final HomeAiSuggestion suggestion;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      key: const Key('ai-suggestion'),
      elevated: true,
      semanticLabel: 'Suggestion IA, ${suggestion.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.control,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(
                    Icons.auto_awesome,
                    color: scheme.onPrimaryContainer,
                    size: AppSizes.iconLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'Suggestion Social Flow AI',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppBadge(label: 'IA', tone: AppBadgeTone.info),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            suggestion.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            suggestion.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTertiaryButton(
            label: suggestion.actionLabel,
            icon: Icons.arrow_forward,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class _PublicationStatusBadge extends StatelessWidget {
  const _PublicationStatusBadge({required this.status});

  final HomePublicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (status) {
      HomePublicationStatus.scheduled => ('Programmé', AppBadgeTone.info),
      HomePublicationStatus.review => ('À valider', AppBadgeTone.warning),
      HomePublicationStatus.published => ('Publié', AppBadgeTone.success),
      HomePublicationStatus.draft => ('Brouillon', AppBadgeTone.neutral),
    };
    return AppBadge(label: label, tone: tone);
  }
}
