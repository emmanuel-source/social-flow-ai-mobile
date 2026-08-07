import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Abonnement',
      description: 'Le mobile affiche les limites et droits du plan; le backend reste la source de vérité pour les quotas et paiements.',
      icon: Icons.workspace_premium_outlined,
      items: ['Plan Free / Creator / Pro / Agency', 'Quotas de comptes sociaux', 'Quotas de publications', 'Crédits IA', 'Historique de facturation côté backend'],
    );
  }
}
