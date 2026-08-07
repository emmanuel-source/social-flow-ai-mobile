import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Brouillons',
      description: 'Conserve les créations incomplètes localement avec Hive et les synchronise avec le backend quand nécessaire.',
      icon: Icons.edit_note_outlined,
      items: ['Autosave', 'Reprise hors ligne', 'Versions de contenu', 'Brouillons par workspace', 'Nettoyage contrôlé du stockage local'],
    );
  }
}
