import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class PublishingQueueScreen extends StatelessWidget {
  const PublishingQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'File de publication',
      description:
          'Suit les contenus prêts, programmés, en cours de publication, publiés ou en erreur sur chaque réseau.',
      icon: Icons.cloud_upload_outlined,
      items: [
        'Adaptation par plateforme',
        'Validation avant envoi',
        'Retries réseau',
        'Statut par compte social',
        'Journal des erreurs API',
      ],
    );
  }
}
