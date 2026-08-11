import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';

enum AppBadgeTone { neutral, info, success, warning, danger }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (background, foreground) = switch (tone) {
      AppBadgeTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      AppBadgeTone.info => (
        isDark
            ? AppColors.info.withValues(alpha: 0.18)
            : AppColors.infoContainer,
        isDark ? const Color(0xFF8EB8FF) : AppColors.info,
      ),
      AppBadgeTone.success => (
        isDark
            ? AppColors.success.withValues(alpha: 0.2)
            : AppColors.successContainer,
        isDark ? const Color(0xFF6EE7A7) : AppColors.success,
      ),
      AppBadgeTone.warning => (
        isDark
            ? AppColors.warning.withValues(alpha: 0.2)
            : AppColors.warningContainer,
        isDark ? const Color(0xFFFBBF6B) : AppColors.warning,
      ),
      AppBadgeTone.danger => (
        isDark
            ? AppColors.danger.withValues(alpha: 0.2)
            : AppColors.dangerContainer,
        isDark ? const Color(0xFFFF8A8A) : AppColors.danger,
      ),
    };
    return Semantics(
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: foreground.withValues(alpha: isDark ? 0.18 : 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconExtraSmall, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
