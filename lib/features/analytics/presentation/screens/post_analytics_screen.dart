import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../widgets/performance_chart.dart';

class PostAnalyticsScreen extends StatelessWidget {
  const PostAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScaffold(title: 'Analyse de la publication', subtitle: 'Instagram · 7 derniers jours', body: Column(children: [Row(children: [MetricCard(label: 'Vues', value: '42.8K', trend: '+22%'), SizedBox(width: 8), MetricCard(label: 'J’aime', value: '3.9K', trend: '+14%'), SizedBox(width: 8), MetricCard(label: 'Partages', value: '870', trend: '+31%')]), SizedBox(height: 24), PerformanceChart()]));
  }
}
