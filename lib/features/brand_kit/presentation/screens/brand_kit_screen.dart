import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_scaffold.dart';

class BrandKitScreen extends StatelessWidget {
  const BrandKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Brand Kit',
      subtitle: 'Identité appliquée à toutes les créations',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ListTile(
            leading: CircleAvatar(child: Text('S')),
            title: Text('Logo principal'),
            subtitle: Text('socialflow_logo.png'),
            trailing: Icon(Icons.edit_outlined),
          ),
          const SizedBox(height: 12),
          Text(
            'Palette',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _ColorSwatch(Color(0xFF6366F1), '#6366F1')),
              SizedBox(width: 8),
              Expanded(child: _ColorSwatch(Color(0xFF8B5CF6), '#8B5CF6')),
              SizedBox(width: 8),
              Expanded(child: _ColorSwatch(Color(0xFF3B82F6), '#3B82F6')),
            ],
          ),
          const SizedBox(height: 18),
          const TextField(
            decoration: InputDecoration(labelText: 'Ton de marque'),
            maxLines: 4,
            controller: null,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Brand Kit enregistré.')),
                ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.color, this.label);
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 90,
    alignment: Alignment.bottomCenter,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
    ),
  );
}
