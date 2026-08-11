import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/social_platform_visuals.dart';
import '../../domain/entities/analytics_dashboard.dart';
import 'analytics_views_chart.dart';

class AnalyticsDashboardContent extends StatelessWidget {
  const AnalyticsDashboardContent({
    required this.dashboard,
    required this.onPeriodSelected,
    required this.onTopContent,
    required this.onCreate,
    super.key,
  });

  final AnalyticsDashboard dashboard;
  final ValueChanged<AnalyticsPeriod> onPeriodSelected;
  final VoidCallback onTopContent;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Statistiques du workspace ${dashboard.workspaceName}, ${_periodLabel(dashboard.period)}',
      child: ListView(
        key: const Key('analytics-scroll'),
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
                  _Header(dashboard: dashboard),
                  const SizedBox(height: AppSpacing.lg),
                  _PeriodSelector(
                    selected: dashboard.period,
                    onSelected: onPeriodSelected,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _KpiSection(kpis: dashboard.kpis),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _ViewsEvolution(dashboard: dashboard),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _PlatformSection(platforms: dashboard.platforms),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _TopContents(
                    contents: dashboard.topContents,
                    onContent: onTopContent,
                  ),
                  if (dashboard.insight case final insight?) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    _InsightCard(insight: insight, onCreate: onCreate),
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

class _Header extends StatelessWidget {
  const _Header({required this.dashboard});

  final AnalyticsDashboard dashboard;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Statistiques',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          if (dashboard.isDemo)
            const AppBadge(label: 'Données démo', tone: AppBadgeTone.info),
        ],
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        dashboard.workspaceName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});

  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Sélection de la période analysée',
    child: Row(
      children: [
        for (var index = 0; index < AnalyticsPeriod.values.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppChip(
              label: _shortPeriodLabel(AnalyticsPeriod.values[index]),
              selected: selected == AnalyticsPeriod.values[index],
              onSelected: (_) => onSelected(AnalyticsPeriod.values[index]),
            ),
          ),
        ],
      ],
    ),
  );
}

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.kpis});

  final List<AnalyticsKpi> kpis;

  @override
  Widget build(BuildContext context) {
    final rows = <List<AnalyticsKpi>>[];
    for (var index = 0; index < kpis.length; index += 2) {
      rows.add(kpis.sublist(index, (index + 2).clamp(0, kpis.length)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Vue d’ensemble',
          subtitle: 'Comparaison avec la période précédente',
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
                  trend: rows[rowIndex][index].change,
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

class _ViewsEvolution extends StatelessWidget {
  const _ViewsEvolution({required this.dashboard});

  final AnalyticsDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final views = dashboard.kpis.firstWhere(
      (kpi) => kpi.type == AnalyticsKpiType.views,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Évolution des vues',
          subtitle: 'Tendance sur la période sélectionnée',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          semanticLabel:
              'Évolution des vues ${views.change}, ${views.comparisonLabel}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${views.value} vues',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  AppBadge(
                    label: views.change,
                    tone: _trendTone(views.direction),
                    icon: _trendIcon(views.direction),
                  ),
                ],
              ),
              AnalyticsViewsChart(points: dashboard.viewsSeries),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlatformSection extends StatelessWidget {
  const _PlatformSection({required this.platforms});

  final List<PlatformPerformance> platforms;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader(
        title: 'Performance par plateforme',
        subtitle: 'Les réseaux qui contribuent le plus à vos résultats',
      ),
      const SizedBox(height: AppSpacing.md),
      SectionCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            for (var index = 0; index < platforms.length; index++) ...[
              Semantics(
                container: true,
                label:
                    '${platforms[index].platform.label}, ${platforms[index].views} vues, ${platforms[index].engagement} engagement, évolution ${platforms[index].change}',
                child: AppListTile(
                  title: platforms[index].platform.label,
                  subtitle:
                      '${platforms[index].views} vues · ${platforms[index].engagement} engagement',
                  leading: SocialPlatformIcon(
                    platform: platforms[index].platform,
                  ),
                  trailing: AppBadge(
                    label: platforms[index].change,
                    tone: _trendTone(platforms[index].direction),
                    icon: _trendIcon(platforms[index].direction),
                  ),
                ),
              ),
              if (index < platforms.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    ],
  );
}

class _TopContents extends StatelessWidget {
  const _TopContents({required this.contents, required this.onContent});

  final List<TopContentPerformance> contents;
  final VoidCallback onContent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader(
        title: 'Meilleurs contenus',
        subtitle: 'Les publications les plus performantes de la période',
      ),
      const SizedBox(height: AppSpacing.md),
      SectionCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            for (var index = 0; index < contents.length; index++) ...[
              Semantics(
                container: true,
                label:
                    'Top ${contents[index].rank}, ${contents[index].platform.label}, ${contents[index].title}, ${contents[index].primaryMetric}, ${contents[index].engagement}',
                child: AppListTile(
                  title: contents[index].title,
                  subtitle:
                      '${contents[index].platform.label} · ${contents[index].contentType}\n${contents[index].primaryMetric} · ${contents[index].engagement}',
                  leading: SocialPlatformIcon(
                    platform: contents[index].platform,
                  ),
                  trailing: AppBadge(
                    label: 'Top ${contents[index].rank}',
                    tone:
                        contents[index].rank == 1
                            ? AppBadgeTone.success
                            : AppBadgeTone.neutral,
                  ),
                  onTap: onContent,
                ),
              ),
              if (index < contents.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    ],
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.onCreate});

  final AnalyticsInsight insight;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      key: const Key('analytics-insight'),
      elevated: true,
      semanticLabel: 'Insight IA, ${insight.title}. ${insight.message}',
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
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.auto_awesome,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: Text('Insight Social Flow AI')),
              const AppBadge(label: 'Démo', tone: AppBadgeTone.info),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(insight.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            insight.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTertiaryButton(
            label: 'Créer un contenu similaire',
            icon: Icons.arrow_forward,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

String _periodLabel(AnalyticsPeriod period) => switch (period) {
  AnalyticsPeriod.sevenDays => '7 derniers jours',
  AnalyticsPeriod.thirtyDays => '30 derniers jours',
  AnalyticsPeriod.ninetyDays => '90 derniers jours',
};

String _shortPeriodLabel(AnalyticsPeriod period) => switch (period) {
  AnalyticsPeriod.sevenDays => '7 jours',
  AnalyticsPeriod.thirtyDays => '30 jours',
  AnalyticsPeriod.ninetyDays => '90 jours',
};

AppBadgeTone _trendTone(AnalyticsTrendDirection direction) =>
    switch (direction) {
      AnalyticsTrendDirection.positive => AppBadgeTone.success,
      AnalyticsTrendDirection.negative => AppBadgeTone.danger,
      AnalyticsTrendDirection.neutral => AppBadgeTone.neutral,
    };

IconData _trendIcon(AnalyticsTrendDirection direction) => switch (direction) {
  AnalyticsTrendDirection.positive => Icons.trending_up,
  AnalyticsTrendDirection.negative => Icons.trending_down,
  AnalyticsTrendDirection.neutral => Icons.trending_flat,
};
