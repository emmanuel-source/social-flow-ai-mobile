import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';

class AgentTestScreen extends StatelessWidget {
  const AgentTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Test de l’agent',
      subtitle: 'Étape 5 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 10),
                Text(
                  '1. Analyse des performances\n2. Génération de 3 idées\n3. Création de brouillons\n4. Demande de validation',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.agentDetail,
                ),
            child: const Text('Activer avec validation'),
          ),
        ],
      ),
    );
  }
}
