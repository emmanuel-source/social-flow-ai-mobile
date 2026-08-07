import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Bibliothèque média',
      description: 'Centralise les images, vidéos, clips, miniatures et ressources réutilisables du workspace.',
      icon: Icons.perm_media_outlined,
      items: ['Import local', 'Médias générés par IA', 'Recherche et filtres', 'Réutilisation dans les publications', 'Cache local et synchronisation backend'],
    );
  }
}
