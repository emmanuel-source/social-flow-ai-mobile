import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Agents & automatisations',
      subtitle: 'Toujours sous votre contrôle',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.agentTemplates),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel agent'),
      ),
      body: Column(
        children: [
          SectionCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.agentDetail),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.auto_awesome)),
              title: Text('Agent Contenu'),
              subtitle: Text('142 actions · approbation obligatoire'),
              trailing: Chip(label: Text('Actif')),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.agentDetail),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.video_library_outlined)),
              title: Text('Agent Vidéo'),
              subtitle: Text('3 clips à valider'),
              trailing: Chip(label: Text('Actif')),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed:
                () => showDialog<void>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Arrêt d'urgence"),
                        content: const Text(
                          'Mettre immédiatement tous les agents en pause ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tout arrêter'),
                          ),
                        ],
                      ),
                ),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text("Arrêt d'urgence"),
          ),
        ],
      ),
    );
  }
}
