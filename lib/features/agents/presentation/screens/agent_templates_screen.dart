import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/agent_controller.dart';

class AgentTemplatesScreen extends ConsumerWidget {
  const AgentTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const templates = ['Création de contenu', 'Transformation vidéo', 'Réponse aux commentaires', 'Analyse des performances', 'Veille des tendances'];
    return FeatureScaffold(title: 'Choisir un modèle', subtitle: 'Étape 1 sur 5', body: Column(children: templates.map((template) => ListTile(leading: const Icon(Icons.smart_toy_outlined), title: Text(template), trailing: const Icon(Icons.chevron_right), onTap: () { ref.read(agentControllerProvider.notifier).setTemplate(template); Navigator.pushNamed(context, AppRoutes.agentConfig); })).toList()));
  }
}
