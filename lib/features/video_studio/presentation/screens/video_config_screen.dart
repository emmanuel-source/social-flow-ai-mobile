import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class VideoConfigScreen extends StatefulWidget {
  const VideoConfigScreen({super.key});

  @override
  State<VideoConfigScreen> createState() => _VideoConfigScreenState();
}

class _VideoConfigScreenState extends State<VideoConfigScreen> {
  double _duration = 35;
  bool _captions = true;
  bool _hooks = true;

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Configuration vidéo',
      subtitle: 'Formats et objectifs',
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Durée cible : ${_duration.round()} secondes'),
        Slider(value: _duration, min: 15, max: 90, divisions: 15, onChanged: (value) => setState(() => _duration = value)),
        SwitchListTile(value: _captions, onChanged: (value) => setState(() => _captions = value), title: const Text('Sous-titres automatiques')),
        SwitchListTile(value: _hooks, onChanged: (value) => setState(() => _hooks = value), title: const Text('Détection des meilleurs hooks')),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.videoAnalysis), child: const Text("Lancer l'analyse IA")),
      ]),
    );
  }
}
