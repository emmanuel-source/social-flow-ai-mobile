import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class PostTypeScreen extends ConsumerWidget {
  const PostTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(composerControllerProvider).type;
    final items = <(PostType, IconData, String)>[
      (PostType.image, Icons.image_outlined, 'Image'),
      (PostType.video, Icons.videocam_outlined, 'Vidéo'),
      (PostType.carousel, Icons.view_carousel_outlined, 'Carrousel'),
      (PostType.text, Icons.text_fields, 'Texte'),
    ];
    return FeatureScaffold(
      title: 'Nouvelle publication',
      subtitle: 'Étape 1 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioGroup<PostType>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                ref.read(composerControllerProvider.notifier).setType(value);
              }
            },
            child: Column(
              children:
                  items
                      .map(
                        (item) => RadioListTile<PostType>(
                          value: item.$1,
                          secondary: Icon(item.$2),
                          title: Text(item.$3),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.postMedia),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
