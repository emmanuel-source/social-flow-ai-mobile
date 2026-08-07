import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Équipe et permissions',
      description: 'Prépare SocialFlow AI pour les marques, entreprises et agences travaillant à plusieurs.',
      icon: Icons.groups_outlined,
      items: ['Invitations', 'Rôles', 'Permissions par workspace', 'Validation avant publication', 'Accès client en lecture/approbation'],
    );
  }
}
