import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../controllers/agent_controller.dart';

class AgentDetailScreen extends ConsumerWidget {
  const AgentDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agent = ref.watch(agentControllerProvider);
    return FeatureScaffold(title: agent.name, subtitle: agent.template, actions: [Switch(value: agent.active, onChanged: ref.read(agentControllerProvider.notifier).setActive)], body: Column(children: [
      const Row(children: [MetricCard(label: 'Actions', value: '142', trend: '+18'), SizedBox(width: 8), MetricCard(label: 'Validées', value: '96%', trend: '+3%'), SizedBox(width: 8), MetricCard(label: 'Temps gagné', value: '8h', trend: '+2h')]),
      const SizedBox(height: 22),
      const ListTile(leading: Icon(Icons.check_circle_outline), title: Text('3 brouillons créés'), subtitle: Text("Aujourd'hui · 09:15")),
      const ListTile(leading: Icon(Icons.analytics_outlined), title: Text('Rapport hebdomadaire analysé'), subtitle: Text('Hier · 18:30')),
      const ListTile(leading: Icon(Icons.schedule), title: Text('Publication programmée'), subtitle: Text('Hier · 14:05')),
    ]));
  }
}
