import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/section_card.dart';
import '../widgets/performance_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rapport PDF généré.')),
                ),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const Row(
            children: [
              MetricCard(label: 'Vues', value: '128K', trend: '+18.6%'),
              SizedBox(width: 8),
              MetricCard(label: 'Engagement', value: '8.4%', trend: '+2.1%'),
              SizedBox(width: 8),
              MetricCard(label: 'Abonnés', value: '+2.8K', trend: '+12%'),
            ],
          ),
          const SizedBox(height: 18),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance sur 7 jours',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 18),
                PerformanceChart(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.postAnalytics),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('IG')),
              title: Text('5 astuces productivité'),
              subtitle: Text('42.8K vues · 9.7% engagement'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
