import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../domain/entities/video_job.dart';
import '../controllers/video_job_controller.dart';

class VideoSourceScreen extends ConsumerWidget {
  const VideoSourceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void choose(VideoSource source, String route) {
      ref.read(videoJobControllerProvider.notifier).setSource(source);
      Navigator.pushNamed(context, route);
    }
    return FeatureScaffold(
      title: 'Transformer une vidéo',
      subtitle: 'Choisissez une source',
      body: Column(children: [
        ListTile(leading: const Icon(Icons.phone_android), title: const Text('Depuis mon appareil'), subtitle: const Text('Importer une vidéo locale'), trailing: const Icon(Icons.chevron_right), onTap: () => choose(VideoSource.device, AppRoutes.videoConfig)),
        ListTile(leading: const Icon(Icons.play_circle_outline), title: const Text('Depuis YouTube'), subtitle: const Text('Coller un lien public'), trailing: const Icon(Icons.chevron_right), onTap: () => choose(VideoSource.youtube, AppRoutes.youtubeImport)),
        ListTile(leading: const Icon(Icons.cloud_outlined), title: const Text('Depuis le cloud'), subtitle: const Text('Bibliothèque SocialFlow'), trailing: const Icon(Icons.chevron_right), onTap: () => choose(VideoSource.cloud, AppRoutes.videoConfig)),
      ]),
    );
  }
}
