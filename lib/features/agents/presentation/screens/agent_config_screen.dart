import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../domain/entities/automation_agent.dart';
import '../controllers/agent_controller.dart';

class AgentConfigScreen extends ConsumerWidget {
  const AgentConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agent = ref.watch(agentControllerProvider);
    return FeatureScaffold(title: 'Configurer l’agent', subtitle: 'Étape 2 sur 5', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(initialValue: agent.name, onChanged: ref.read(agentControllerProvider.notifier).setName, decoration: const InputDecoration(labelText: 'Nom de l’agent')),
      const SizedBox(height: 14),
      DropdownButtonFormField<AgentAutonomy>(initialValue: agent.autonomy, decoration: const InputDecoration(labelText: 'Niveau d’autonomie'), items: const [DropdownMenuItem(value: AgentAutonomy.approvalRequired, child: Text('Approbation obligatoire')), DropdownMenuItem(value: AgentAutonomy.supervised, child: Text('Supervisé')), DropdownMenuItem(value: AgentAutonomy.autonomous, child: Text('Autonome'))], onChanged: (value) => ref.read(agentControllerProvider.notifier).setAutonomy(value!)),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.agentPermissions), child: const Text('Continuer')),
    ]));
  }
}
