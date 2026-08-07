import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class SubtitlesScreen extends StatefulWidget {
  const SubtitlesScreen({super.key});

  @override
  State<SubtitlesScreen> createState() => _SubtitlesScreenState();
}

class _SubtitlesScreenState extends State<SubtitlesScreen> {
  int _style = 0;

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Sous-titres',
      subtitle: 'Style, langue et surlignage',
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('Minimal')), ButtonSegment(value: 1, label: Text('Dynamique')), ButtonSegment(value: 2, label: Text('Karaoké'))], selected: {_style}, onSelectionChanged: (value) => setState(() => _style = value.first)),
        const SizedBox(height: 22),
        Container(height: 360, padding: const EdgeInsets.all(28), alignment: Alignment.bottomCenter, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)), child: const Text('Créez du contenu qui marque', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.postPreview), child: const Text('Utiliser ce clip')),
      ]),
    );
  }
}
