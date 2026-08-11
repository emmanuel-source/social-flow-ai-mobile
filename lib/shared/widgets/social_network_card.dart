import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../models/social_platform.dart';
import 'app_card.dart';
import 'social_platform_visuals.dart';

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
    final statusLabel =
        !compatible
            ? 'Indisponible'
            : connected
            ? 'Connecté'
            : 'Non connecté';
    final statusTone =
        !compatible
            ? SocialPlatformStatusTone.warning
            : connected
            ? SocialPlatformStatusTone.success
            : SocialPlatformStatusTone.neutral;
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
              SocialPlatformIcon(
                platform: platform,
                containerSize: compact ? 32 : 36,
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
              SocialPlatformStatus(label: statusLabel, tone: statusTone),
              if (selected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.check_circle_outline,
                  size: AppSizes.iconMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
