import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../models/social_platform.dart';

@immutable
class SocialPlatformVisuals {
  const SocialPlatformVisuals({
    required this.label,
    required this.icon,
    required this.brandColor,
    required this.subtleBackground,
    this.prefersNeutralIcon = false,
  });

  final String label;
  final FaIconData icon;
  final Color brandColor;
  final Color subtleBackground;
  final bool prefersNeutralIcon;

  static SocialPlatformVisuals of(SocialPlatform platform) =>
      switch (platform) {
        SocialPlatform.instagram => const SocialPlatformVisuals(
          label: 'Instagram',
          icon: FontAwesomeIcons.instagram,
          brandColor: AppColors.instagram,
          subtleBackground: Color(0x1AE1306C),
        ),
        SocialPlatform.facebook => const SocialPlatformVisuals(
          label: 'Facebook',
          icon: FontAwesomeIcons.facebookF,
          brandColor: AppColors.facebook,
          subtleBackground: Color(0x1A1877F2),
        ),
        SocialPlatform.tiktok => const SocialPlatformVisuals(
          label: 'TikTok',
          icon: FontAwesomeIcons.tiktok,
          brandColor: AppColors.tiktok,
          subtleBackground: Color(0x14111111),
          prefersNeutralIcon: true,
        ),
        SocialPlatform.youtube => const SocialPlatformVisuals(
          label: 'YouTube',
          icon: FontAwesomeIcons.youtube,
          brandColor: AppColors.youtube,
          subtleBackground: Color(0x1AFF0000),
        ),
        SocialPlatform.snapchat => const SocialPlatformVisuals(
          label: 'Snapchat',
          icon: FontAwesomeIcons.snapchat,
          brandColor: AppColors.snapchat,
          subtleBackground: Color(0x29F5C400),
          prefersNeutralIcon: true,
        ),
        SocialPlatform.x => const SocialPlatformVisuals(
          label: 'X',
          icon: FontAwesomeIcons.xTwitter,
          brandColor: AppColors.x,
          subtleBackground: Color(0x14111111),
          prefersNeutralIcon: true,
        ),
        SocialPlatform.linkedin => const SocialPlatformVisuals(
          label: 'LinkedIn',
          icon: FontAwesomeIcons.linkedinIn,
          brandColor: AppColors.linkedin,
          subtleBackground: Color(0x1A0A66C2),
        ),
        SocialPlatform.pinterest => const SocialPlatformVisuals(
          label: 'Pinterest',
          icon: FontAwesomeIcons.pinterestP,
          brandColor: AppColors.pinterest,
          subtleBackground: Color(0x1AE60023),
        ),
        SocialPlatform.threads => const SocialPlatformVisuals(
          label: 'Threads',
          icon: FontAwesomeIcons.threads,
          brandColor: AppColors.threads,
          subtleBackground: Color(0x14222222),
          prefersNeutralIcon: true,
        ),
      };

  Color iconColorFor(BuildContext context) {
    if (!prefersNeutralIcon) return brandColor;
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? scheme.onSurface
        : AppColors.brandNavy;
  }

  Color backgroundFor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return subtleBackground;
    }
    return iconColorFor(context).withValues(alpha: 0.12);
  }
}

class SocialPlatformIcon extends StatelessWidget {
  const SocialPlatformIcon({
    required this.platform,
    this.size = AppSizes.iconSmall,
    this.containerSize = AppSizes.avatarSmall,
    this.contained = true,
    this.semanticLabel,
    super.key,
  });

  final SocialPlatform platform;
  final double size;
  final double containerSize;
  final bool contained;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final visuals = SocialPlatformVisuals.of(platform);
    final icon = FaIcon(
      visuals.icon,
      size: size,
      color: visuals.iconColorFor(context),
    );
    return Semantics(
      image: true,
      label: semanticLabel ?? visuals.label,
      child: ExcludeSemantics(
        child:
            contained
                ? SizedBox.square(
                  dimension: containerSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: visuals.backgroundFor(context),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(child: icon),
                  ),
                )
                : icon,
      ),
    );
  }
}

class SocialPlatformChip extends StatelessWidget {
  const SocialPlatformChip({
    required this.platform,
    required this.selected,
    required this.onSelected,
    this.showLabel = true,
    this.semanticLabel,
    super.key,
  });

  final SocialPlatform platform;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool showLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final visuals = SocialPlatformVisuals.of(platform);
    return Semantics(
      label:
          semanticLabel ??
          '${visuals.label}, ${selected ? 'sélectionné' : 'non sélectionné'}',
      selected: selected,
      button: true,
      child: FilterChip(
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        avatarBoxConstraints: const BoxConstraints.tightFor(
          width: AppSizes.iconMedium,
          height: AppSizes.iconMedium,
        ),
        avatar: SocialPlatformIcon(
          platform: platform,
          size: AppSizes.iconExtraSmall,
          contained: false,
        ),
        label:
            showLabel
                ? Text(visuals.label, overflow: TextOverflow.ellipsis)
                : const SizedBox.shrink(),
        labelPadding:
            showLabel
                ? const EdgeInsets.only(left: AppSpacing.xs)
                : EdgeInsets.zero,
      ),
    );
  }
}

class SocialPlatformLabel extends StatelessWidget {
  const SocialPlatformLabel({required this.platform, super.key});

  final SocialPlatform platform;

  @override
  Widget build(BuildContext context) {
    final visuals = SocialPlatformVisuals.of(platform);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: visuals.label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SocialPlatformIcon(
                  platform: platform,
                  size: AppSizes.iconExtraSmall,
                  contained: false,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  visuals.label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SocialPlatformStatusTone { success, warning, neutral }

class SocialPlatformStatus extends StatelessWidget {
  const SocialPlatformStatus({
    required this.label,
    this.tone = SocialPlatformStatusTone.neutral,
    super.key,
  });

  final String label;
  final SocialPlatformStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      SocialPlatformStatusTone.success => AppColors.success,
      SocialPlatformStatusTone.warning => AppColors.warning,
      SocialPlatformStatusTone.neutral => scheme.onSurfaceVariant,
    };
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
