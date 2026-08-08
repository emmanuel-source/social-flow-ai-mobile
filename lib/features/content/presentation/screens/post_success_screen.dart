import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/providers/core_providers.dart';

class PostSuccessScreen extends ConsumerWidget {
  const PostSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.check,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Publication programmée !',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre contenu sera publié automatiquement sur les plateformes sélectionnées.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (_) => false,
                    ),
                child: const Text("Retour à l'accueil"),
              ),
              TextButton.icon(
                onPressed:
                    () => ref
                        .read(shareServiceProvider)
                        .shareText(
                          text:
                              'Découvrez ma prochaine publication SocialFlow AI !',
                        ),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Partager'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
