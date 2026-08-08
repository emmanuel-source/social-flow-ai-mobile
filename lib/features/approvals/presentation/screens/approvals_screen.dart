import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Validations',
      description:
          'Workflow de validation utile aux équipes et agences avant qu’un contenu ne puisse être publié.',
      icon: Icons.fact_check_outlined,
      items: [
        'Soumettre pour validation',
        'Commentaires internes',
        'Approuver/refuser',
        'Historique de décision',
        'Verrouillage avant publication',
      ],
    );
  }
}
