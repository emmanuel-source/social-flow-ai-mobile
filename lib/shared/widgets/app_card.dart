import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.elevated = false,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Ink(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: elevated ? AppShadows.subtle(theme.brightness) : null,
      ),
      child: child,
    );

    final card =
        onTap == null
            ? content
            : InkWell(
              onTap: onTap,
              borderRadius: AppRadius.card,
              child: content,
            );
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      container: true,
      child: card,
    );
  }
}
