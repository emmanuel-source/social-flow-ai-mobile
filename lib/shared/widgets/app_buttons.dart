import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = !loading && onPressed != null;
    final scheme = Theme.of(context).colorScheme;
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? AppGradients.primaryAction : null,
        color: enabled ? null : scheme.surfaceContainerHighest,
        borderRadius: AppRadius.control,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: scheme.onPrimary,
          disabledForegroundColor: scheme.onSurfaceVariant,
          shadowColor: Colors.transparent,
        ),
        onPressed: loading ? null : onPressed,
        child: _ButtonContent(label: label, icon: icon, loading: loading),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: _ButtonContent(label: label, icon: icon, loading: loading),
    );
    return Semantics(
      button: true,
      label: label,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final button =
        icon == null
            ? TextButton(onPressed: onPressed, child: Text(label))
            : TextButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            );
    return Semantics(button: true, label: label, child: button);
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor:
              selected ? scheme.primaryContainer : Colors.transparent,
          foregroundColor: selected ? scheme.primary : scheme.onSurfaceVariant,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        isSelected: selected,
        icon: Icon(icon),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
  });

  final String label;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox.square(
        dimension: AppSizes.iconMedium,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconMedium),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: Text(label)),
        ],
      );
    }
    return Text(label, maxLines: 2, overflow: TextOverflow.ellipsis);
  }
}
