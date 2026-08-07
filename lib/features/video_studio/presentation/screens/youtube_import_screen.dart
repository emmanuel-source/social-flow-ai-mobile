import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/video_job_controller.dart';

class YoutubeImportScreen extends ConsumerStatefulWidget {
  const YoutubeImportScreen({super.key});

  @override
  ConsumerState<YoutubeImportScreen> createState() => _YoutubeImportScreenState();
}

class _YoutubeImportScreenState extends ConsumerState<YoutubeImportScreen> {
  final _url = TextEditingController(text: 'https://youtube.com/watch?v=demo');

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Importer YouTube',
      subtitle: 'Créez des clips à partir d’une vidéo',
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Lien YouTube', prefixIcon: Icon(Icons.link))),
        const SizedBox(height: 16),
        Container(height: 190, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFFFB923C)])), child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 68))),
        const SizedBox(height: 22),
        FilledButton(onPressed: () { ref.read(videoJobControllerProvider.notifier).setUrl(_url.text); Navigator.pushNamed(context, AppRoutes.videoConfig); }, child: const Text('Analyser la vidéo')),
      ]),
    );
  }
}
