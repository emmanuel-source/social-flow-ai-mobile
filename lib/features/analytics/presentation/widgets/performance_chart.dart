import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceChart extends StatelessWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 16,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 4,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .12),
              ),
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 5),
                FlSpot(2, 4),
                FlSpot(3, 8),
                FlSpot(4, 7),
                FlSpot(5, 12),
                FlSpot(6, 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
