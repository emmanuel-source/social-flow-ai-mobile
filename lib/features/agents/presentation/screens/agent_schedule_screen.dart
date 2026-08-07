import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class AgentScheduleScreen extends StatelessWidget {
  const AgentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(title: 'Fréquence', subtitle: 'Étape 4 sur 5', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      RadioGroup<int>(
        groupValue: 1,
        onChanged: (_) {},
        child: const Column(
          children: [
            RadioListTile(value: 1, title: Text('Tous les jours à 08:00')),
            RadioListTile(value: 2, title: Text('Chaque lundi')),
            RadioListTile(value: 3, title: Text('Lorsqu’un événement arrive')),
          ],
        ),
      ),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.agentTest), child: const Text('Tester l’agent')),
    ]));
  }
}
