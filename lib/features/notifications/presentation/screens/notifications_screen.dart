import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Notifications',
      description: 'Regroupe les publications réussies ou échouées, validations, commentaires importants et résultats des traitements IA.',
      icon: Icons.notifications_none,
      items: ['Publication réussie/échouée', 'Clip prêt à valider', 'Demande d’approbation', 'Nouveau commentaire prioritaire', 'Alerte connexion de compte social'],
    );
  }
}
