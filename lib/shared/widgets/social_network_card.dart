import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../models/social_platform.dart';
import 'app_badge.dart';
import 'app_card.dart';

class SocialNetworkCard extends StatelessWidget {
  const SocialNetworkCard({
    required this.platform,
    required this.onTap,
    this.accountLabel,
    this.connected = false,
    this.selected = false,
    this.compatible = true,
    this.compact = false,
    super.key,
  });

  final SocialPlatform platform;
  final VoidCallback? onTap;
  final String? accountLabel;
  final bool connected;
  final bool selected;
  final bool compatible;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(platform);
    final statusLabel =
        !compatible
            ? 'Indisponible'
            : connected
            ? 'Connecté'
            : 'Non connecté';
    final statusTone =
        !compatible
            ? AppBadgeTone.warning
            : connected
            ? AppBadgeTone.success
            : AppBadgeTone.neutral;
    final accessibilityLabel = [
      platform.label,
      if (accountLabel != null) accountLabel!,
      connected ? 'connecté' : 'non connecté',
      compatible ? 'compatible' : 'indisponible pour ce contenu',
      selected ? 'sélectionné' : 'non sélectionné',
    ].join(', ');

    return Semantics(
      container: true,
      button: onTap != null,
      selected: selected,
      label: accessibilityLabel,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onTap,
          padding:
              compact
                  ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  )
                  : const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Text(
                  _platformMonogram(platform),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform.label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (accountLabel != null)
                      Text(
                        accountLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: statusLabel, tone: statusTone),
              if (selected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _platformColor(SocialPlatform platform) => switch (platform) {
    SocialPlatform.instagram => AppColors.instagram,
    SocialPlatform.facebook => AppColors.facebook,
    SocialPlatform.tiktok => AppColors.tiktok,
    SocialPlatform.youtube => AppColors.youtube,
    SocialPlatform.snapchat => AppColors.snapchat,
    SocialPlatform.x => AppColors.x,
    SocialPlatform.linkedin => AppColors.linkedin,
    SocialPlatform.pinterest => AppColors.pinterest,
    SocialPlatform.threads => AppColors.threads,
  };

  static String _platformMonogram(SocialPlatform platform) =>
      switch (platform) {
        SocialPlatform.instagram => 'IG',
        SocialPlatform.facebook => 'FB',
        SocialPlatform.tiktok => 'TT',
        SocialPlatform.youtube => 'YT',
        SocialPlatform.snapchat => 'SC',
        SocialPlatform.x => 'X',
        SocialPlatform.linkedin => 'IN',
        SocialPlatform.pinterest => 'PI',
        SocialPlatform.threads => 'TH',
      };
}
