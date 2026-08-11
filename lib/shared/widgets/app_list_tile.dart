import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      minTileHeight: 48,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      horizontalTitleGap: AppSpacing.sm,
      minVerticalPadding: AppSpacing.xs,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
      leading: leading,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      trailing:
          trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right)),
    );
  }
}
