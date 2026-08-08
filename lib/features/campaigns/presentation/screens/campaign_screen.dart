import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  String _goal = 'Notoriété';

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Campagne intelligente',
      subtitle: 'Un objectif devient un plan multicanal',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _goal,
            items:
                const ['Notoriété', 'Engagement', 'Ventes', 'Lancement']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (value) => setState(() => _goal = value!),
            decoration: const InputDecoration(labelText: 'Objectif'),
          ),
          const SizedBox(height: 14),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Décrivez votre campagne',
              hintText: 'Produit, audience, offre et dates…',
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(labelText: 'Budget indicatif'),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '11 publications et un calendrier ont été générés.',
                  ),
                ),
              );
              Navigator.pushNamed(context, AppRoutes.calendar);
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Générer la campagne'),
          ),
        ],
      ),
    );
  }
}
