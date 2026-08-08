import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/agent_controller.dart';

class AgentPermissionsScreen extends ConsumerWidget {
  const AgentPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(agentControllerProvider).permissions;
    const all = [
      'Lire les statistiques',
      'Créer des brouillons',
      'Programmer des publications',
      'Répondre aux commentaires',
      'Publier sans validation',
    ];
    return FeatureScaffold(
      title: 'Permissions',
      subtitle: 'Étape 3 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...all.map(
            (permission) => CheckboxListTile(
              value: permissions.contains(permission),
              onChanged:
                  (_) => ref
                      .read(agentControllerProvider.notifier)
                      .togglePermission(permission),
              title: Text(permission),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.agentSchedule),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
