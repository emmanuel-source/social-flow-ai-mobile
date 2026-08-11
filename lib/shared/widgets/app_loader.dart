import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({this.label = 'Chargement', this.compact = false, super.key});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: Center(
        child:
            compact
                ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
      ),
    );
  }
}
