import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../domain/entities/video_job.dart';
import '../controllers/video_job_controller.dart';

class VideoAnalysisScreen extends ConsumerStatefulWidget {
  const VideoAnalysisScreen({super.key});

  @override
  ConsumerState<VideoAnalysisScreen> createState() =>
      _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends ConsumerState<VideoAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(videoJobControllerProvider.notifier).startAnalysis();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.clips);
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(videoJobControllerProvider);
    final label = switch (job.status) {
      VideoJobStatus.preparing => 'Préparation du fichier…',
      VideoJobStatus.transcribing => 'Transcription et langue…',
      VideoJobStatus.analyzing => 'Analyse des sujets importants…',
      VideoJobStatus.clipping => 'Création des clips et sous-titres…',
      VideoJobStatus.completed => 'Finalisation…',
      _ => 'Initialisation…',
    };
    return FeatureScaffold(
      title: 'Analyse en cours',
      showBack: false,
      body: SizedBox(
        height: 520,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: job.progress / 100,
                    strokeWidth: 12,
                  ),
                ),
                Text(
                  '${job.progress}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            const Text(
              'Vous pouvez quitter cet écran : le traitement continuera en arrière-plan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
