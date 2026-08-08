import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/composer_controller.dart';

class MediaPickerScreen extends ConsumerWidget {
  const MediaPickerScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final service = ref.read(mediaServiceProvider);
    final images = await service.pickImages();
    final compressed = <String>[];
    for (final image in images) {
      final result = await service.compressImage(image);
      compressed.add((result ?? image).path);
    }
    ref.read(composerControllerProvider.notifier).setMedia(compressed);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${compressed.length} média(s) sélectionné(s).')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paths = ref.watch(composerControllerProvider).mediaPaths;
    return FeatureScaffold(
      title: 'Choisir les médias',
      subtitle: 'Étape 2 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _pick(context, ref),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Ouvrir la galerie'),
          ),
          const SizedBox(height: 16),
          if (paths.isEmpty)
            Container(
              height: 230,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 52),
                  SizedBox(height: 10),
                  Text('Sélectionnez jusqu’à 10 images'),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  paths
                      .map(
                        (path) => Chip(
                          avatar: const Icon(Icons.image, size: 18),
                          label: Text(
                            path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.postCaption),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
