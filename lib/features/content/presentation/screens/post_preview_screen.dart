import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/composer_controller.dart';

class PostPreviewScreen extends ConsumerWidget {
  const PostPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(composerControllerProvider);
    return FeatureScaffold(
      title: 'Aperçu',
      subtitle: 'Vérifiez avant de programmer',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppNetworkImage(
            url:
                'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=1200',
          ),
          const SizedBox(height: 14),
          Text(post.caption, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children:
                post.platforms.map((e) => Chip(label: Text(e.label))).toList(),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.postSchedule),
            child: const Text('Planifier la publication'),
          ),
        ],
      ),
    );
  }
}
