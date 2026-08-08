import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Assistant SocialFlow AI',
      description:
          'Assistant transversal pour trouver des idées, rédiger, réécrire, traduire et adapter un contenu selon chaque réseau.',
      icon: Icons.auto_awesome,
      items: [
        'Idées de contenu',
        'Légendes et hashtags',
        'Scripts vidéo',
        'Traduction',
        'Réécriture selon la plateforme',
        'Suggestions basées sur les performances',
      ],
    );
  }
}
