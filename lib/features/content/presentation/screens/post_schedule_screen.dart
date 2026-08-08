import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class PostScheduleScreen extends ConsumerWidget {
  const PostScheduleScreen({super.key});

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    await ref.read(composerControllerProvider.notifier).publish();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.postSuccess,
      ModalRoute.withName(AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(composerControllerProvider).mode;
    return FeatureScaffold(
      title: 'Publication',
      subtitle: 'Étape 5 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioGroup<PublicationMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) {
                ref.read(composerControllerProvider.notifier).setMode(value);
              }
            },
            child: const Column(
              children: [
                RadioListTile(
                  value: PublicationMode.now,
                  title: Text('Publier maintenant'),
                ),
                RadioListTile(
                  value: PublicationMode.scheduled,
                  title: Text('Programmer'),
                  subtitle: Text('Demain à 10:00 · horaire recommandé'),
                ),
                RadioListTile(
                  value: PublicationMode.draft,
                  title: Text('Enregistrer en brouillon'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => _publish(context, ref),
            child: Text(mode == PublicationMode.now ? 'Publier' : 'Confirmer'),
          ),
        ],
      ),
    );
  }
}
