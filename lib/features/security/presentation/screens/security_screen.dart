import 'package:flutter/material.dart';

import '../../../../shared/widgets/future_feature_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FutureFeatureScreen(
      title: 'Sécurité',
      description: 'Centralise les sessions, appareils, sécurité du compte et règles d’accès de l’utilisateur.',
      icon: Icons.security_outlined,
      items: ['Sessions actives', 'Déconnexion des appareils', '2FA côté backend', 'Journal de sécurité', 'Révocation des jetons'],
    );
  }
}
