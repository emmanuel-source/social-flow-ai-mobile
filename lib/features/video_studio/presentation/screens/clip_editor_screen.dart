import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class ClipEditorScreen extends StatelessWidget {
  const ClipEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Éditeur de clip',
      subtitle: 'Recadrage vertical intelligent',
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 420, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 70))),
        const SizedBox(height: 14),
        const Text('00:12 ━━━━━●━━━━ 00:42', textAlign: TextAlign.center),
        const SizedBox(height: 18),
        FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.subtitles), child: const Text('Configurer les sous-titres')),
      ]),
    );
  }
}
