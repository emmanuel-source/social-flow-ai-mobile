import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/composer_controller.dart';

class CaptionScreen extends ConsumerStatefulWidget {
  const CaptionScreen({super.key});

  @override
  ConsumerState<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends ConsumerState<CaptionScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(composerControllerProvider).caption,
    );
  }

  void _syncFromState() {
    final value = ref.read(composerControllerProvider).caption;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Rédiger la légende',
      subtitle: 'Étape 3 sur 5',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: 8,
            onChanged: ref.read(composerControllerProvider.notifier).setCaption,
            decoration: const InputDecoration(
              labelText: 'Légende',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('✦ Améliorer'),
                onPressed: () {
                  ref
                      .read(composerControllerProvider.notifier)
                      .improveCaption();
                  _syncFromState();
                },
              ),
              ActionChip(
                label: const Text('Raccourcir'),
                onPressed: () {
                  ref
                      .read(composerControllerProvider.notifier)
                      .shortenCaption();
                  _syncFromState();
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.postPlatforms),
            child: const Text('Choisir les plateformes'),
          ),
        ],
      ),
    );
  }
}
