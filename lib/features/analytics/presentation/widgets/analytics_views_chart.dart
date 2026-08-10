import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/analytics_dashboard.dart';

class AnalyticsViewsChart extends StatelessWidget {
  const AnalyticsViewsChart({required this.points, super.key});

  final List<AnalyticsTimePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('Aucune donnée pour cette période')),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final values = points.map((point) => point.value);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final change = points.last.value - points.first.value;
    final direction = change >= 0 ? 'hausse' : 'baisse';

    return Semantics(
      container: true,
      label:
          'Graphique des vues, $direction de ${points.first.value.toStringAsFixed(1)} à ${points.last.value.toStringAsFixed(1)} milliers',
      child: ExcludeSemantics(
        child: SizedBox(
          key: const Key('analytics-views-chart'),
          height: 220,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: (minValue * 0.75).clamp(0, double.infinity),
                maxY: maxValue * 1.15,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 3,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: scheme.outlineVariant.withValues(alpha: 0.65),
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: maxValue / 3,
                      getTitlesWidget:
                          (value, meta) => Text(
                            '${value.toStringAsFixed(0)} K',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final middle = points.length ~/ 2;
                        if (index != 0 &&
                            index != middle &&
                            index != points.length - 1) {
                          return const SizedBox.shrink();
                        }
                        final date = points[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => scheme.inverseSurface,
                    getTooltipItems:
                        (spots) => [
                          for (final spot in spots)
                            LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)} K vues',
                              TextStyle(color: scheme.onInverseSurface),
                            ),
                        ],
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var index = 0; index < points.length; index++)
                        FlSpot(index.toDouble(), points[index].value),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: scheme.primary,
                    barWidth: 3,
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
        ),
      ),
    );
  }
}
