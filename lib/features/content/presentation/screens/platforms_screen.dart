import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/composer_controller.dart';

class PlatformsScreen extends ConsumerWidget {
  const PlatformsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(composerControllerProvider).platforms;
    return FeatureScaffold(
      title: 'Plateformes',
      subtitle: 'Étape 4 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...SocialPlatform.values.map(
            (platform) => CheckboxListTile(
              value: selected.contains(platform),
              onChanged:
                  (_) => ref
                      .read(composerControllerProvider.notifier)
                      .togglePlatform(platform),
              title: Text(platform.label),
              secondary: const CircleAvatar(
                child: Icon(Icons.public, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed:
                selected.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.postPreview),
            child: const Text('Prévisualiser'),
          ),
        ],
      ),
    );
  }
}
