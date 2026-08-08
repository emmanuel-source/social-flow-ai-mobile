import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../workspaces/presentation/controllers/workspace_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceControllerProvider).current;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour 👋',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              workspace.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.inbox),
            icon: const Icon(Icons.inbox_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Text('SM')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            children: [
              ActionTile(
                icon: Icons.add,
                title: 'Nouvelle publication',
                subtitle: 'Publier partout',
                onTap: () => Navigator.pushNamed(context, AppRoutes.postType),
              ),
              ActionTile(
                icon: Icons.play_circle_outline,
                title: 'Importer YouTube',
                subtitle: 'Créer des clips',
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.youtubeImport),
              ),
              ActionTile(
                icon: Icons.auto_awesome,
                title: 'Assistant IA',
                subtitle: 'Créer plus vite',
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.aiAssistant),
              ),
              ActionTile(
                icon: Icons.smart_toy_outlined,
                title: 'Automatisations',
                subtitle: 'Gagner du temps',
                onTap: () => Navigator.pushNamed(context, AppRoutes.agents),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              MetricCard(label: 'Programmées', value: '5', trend: '+2'),
              SizedBox(width: 8),
              MetricCard(label: 'Clips', value: '3', trend: '65%'),
              SizedBox(width: 8),
              MetricCard(label: 'Vues', value: '12.4K', trend: '+18.6%'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Publications à venir',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    () =>
                        Navigator.pushNamed(context, AppRoutes.publishingQueue),
                child: const Text('Voir la file'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SectionCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.calendarDetail),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('IG')),
              title: Text('5 astuces pour booster votre productivité'),
              subtitle: Text("Aujourd'hui · 10:00 · Instagram"),
              trailing: Chip(label: Text('Programmé')),
            ),
          ),
          const SizedBox(height: 10),
          SectionCard(
            onTap: () => Navigator.pushNamed(context, AppRoutes.agents),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('AI')),
              title: Text('Agent Vidéo'),
              subtitle: Text('3 Shorts prêts à valider'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
