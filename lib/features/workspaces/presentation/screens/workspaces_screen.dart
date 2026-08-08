import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/workspace_controller.dart';

class WorkspacesScreen extends ConsumerWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Espaces de travail',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Un espace sépare les marques, clients, comptes sociaux, contenus et statistiques.',
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: state.current.id,
            onChanged: (workspaceId) {
              if (workspaceId == null) return;
              final workspace = state.available.firstWhere(
                (candidate) => candidate.id == workspaceId,
              );
              ref.read(workspaceControllerProvider.notifier).select(workspace);
            },
            child: Column(
              children: state.available
                  .map(
                    (workspace) => Card(
                      child: RadioListTile<String>(
                        value: workspace.id,
                        title: Text(workspace.name),
                        subtitle: Text(workspace.type.name),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Créer un espace'),
          ),
        ],
      ),
    );
  }
}
