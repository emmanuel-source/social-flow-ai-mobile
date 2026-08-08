import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';

enum AppAvatarSize { small, medium, large }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.label,
    this.imageUrl,
    this.icon,
    this.size = AppAvatarSize.medium,
    super.key,
  });

  final String label;
  final String? imageUrl;
  final IconData? icon;
  final AppAvatarSize size;

  double get _diameter => switch (size) {
    AppAvatarSize.small => AppSizes.avatarSmall,
    AppAvatarSize.medium => AppSizes.avatarMedium,
    AppAvatarSize.large => AppSizes.avatarLarge,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials =
        label
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part.substring(0, 1).toUpperCase())
            .join();
    return Semantics(
      image: imageUrl != null,
      label: label,
      child: CircleAvatar(
        radius: _diameter / 2,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
        child:
            imageUrl != null
                ? null
                : icon != null
                ? Icon(icon)
                : Text(initials, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
