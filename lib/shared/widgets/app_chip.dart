import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.icon,
    this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final IconData? icon;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      avatarBoxConstraints: const BoxConstraints.tightFor(
        width: AppSizes.iconMedium,
        height: AppSizes.iconMedium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      selected: selected,
      avatar: icon == null ? null : Icon(icon),
      onSelected: enabled ? onSelected : null,
    );
  }
}
