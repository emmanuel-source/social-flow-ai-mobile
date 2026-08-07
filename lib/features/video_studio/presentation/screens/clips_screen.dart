import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';

class ClipsScreen extends StatelessWidget {
  const ClipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Clips générés',
      subtitle: '3 meilleurs moments détectés',
      body: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SectionCard(
              onTap: () => Navigator.pushNamed(context, AppRoutes.clipEditor),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Clip ${index + 1} · ${25 + index * 8}s'),
                subtitle: Text(
                  'Score viral ${92 - index * 5}% · Hook détecté',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
