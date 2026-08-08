import 'package:flutter/material.dart';

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
      label: Text(label, overflow: TextOverflow.ellipsis),
      selected: selected,
      avatar: icon == null ? null : Icon(icon),
      onSelected: enabled ? onSelected : null,
    );
  }
}
