import 'package:flutter/material.dart';

import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/social_platform_visuals.dart';

class SocialAccountsScreen extends StatelessWidget {
  const SocialAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = [
      (SocialPlatform.instagram, '@sarahcreates', true),
      (SocialPlatform.facebook, 'Sarah Miller Studio', true),
      (SocialPlatform.tiktok, '@sarahcreates', true),
      (SocialPlatform.youtube, 'Sarah Miller', true),
      (SocialPlatform.linkedin, 'Non connecté', false),
      (SocialPlatform.x, 'Non connecté', false),
    ];
    return FeatureScaffold(
      title: 'Comptes sociaux',
      subtitle: 'Connexions OAuth et permissions',
      body: Column(
        children:
            accounts
                .map(
                  (account) => ListTile(
                    leading: SocialPlatformIcon(platform: account.$1),
                    title: Text(account.$1.label),
                    subtitle: Text(account.$2),
                    trailing:
                        account.$3
                            ? OutlinedButton(
                              onPressed: () {},
                              child: const Text('Gérer'),
                            )
                            : FilledButton(
                              onPressed:
                                  () => ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Connexion ${account.$1.label} ouverte.',
                                      ),
                                    ),
                                  ),
                              child: const Text('Connecter'),
                            ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
