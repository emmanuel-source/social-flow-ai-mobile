import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';
import '../models/demo_social_account.dart';
import '../widgets/platform_post_preview_card.dart';

class PostPreviewScreen extends ConsumerStatefulWidget {
  const PostPreviewScreen({this.onEditPlatform, this.onContinue, super.key});

  final ValueChanged<SocialPlatform>? onEditPlatform;
  final ValueChanged<SocialPost>? onContinue;

  @override
  ConsumerState<PostPreviewScreen> createState() => _PostPreviewScreenState();
}

class _PostPreviewScreenState extends ConsumerState<PostPreviewScreen> {
  SocialPlatform? _activePlatform;

  @override
  void initState() {
    super.initState();
    final platforms = _orderedPlatforms(
      ref.read(composerControllerProvider).platforms,
    );
    _activePlatform = platforms.isEmpty ? null : platforms.first;
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(composerControllerProvider);
    final platforms = _orderedPlatforms(post.platforms);
    final activePlatform =
        platforms.contains(_activePlatform)
            ? _activePlatform
            : (platforms.isEmpty ? null : platforms.first);
    final variant =
        activePlatform == null ? null : post.platformVariants[activePlatform];

    return FeatureScaffold(
      title: 'Prévisualiser',
      subtitle: 'Étape 5 · Vérification',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Vérifiez chaque version',
            subtitle:
                'Aperçu Social Flow AI avant publication ou programmation.',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (platforms.isEmpty)
            const AppCard(
              child: Text(
                'Aucune plateforme sélectionnée. Revenez à l’étape précédente pour préparer le Preview.',
              ),
            )
          else ...[
            SingleChildScrollView(
              key: const Key('preview-platform-selector'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < platforms.length; index++) ...[
                    Semantics(
                      selected: platforms[index] == activePlatform,
                      label:
                          '${platforms[index].label}, ${platforms[index] == activePlatform ? 'preview actif' : 'preview inactif'}',
                      child: AppChip(
                        key: Key('preview-${platforms[index].name}'),
                        label: platforms[index].label,
                        selected: platforms[index] == activePlatform,
                        onSelected:
                            (_) => setState(
                              () => _activePlatform = platforms[index],
                            ),
                      ),
                    ),
                    if (index < platforms.length - 1)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(
              title: 'Aperçu',
              subtitle:
                  'Présentation indicative, sans reproduire une interface propriétaire.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (activePlatform != null && variant != null)
              PlatformPostPreviewCard(
                key: ValueKey(activePlatform),
                post: post,
                variant: variant,
                account: demoAccountFor(activePlatform),
              )
            else
              const AppCard(
                child: Text(
                  'Cette variante est absente. Revenez à l’adaptation pour la recréer.',
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            AppSecondaryButton(
              key: const Key('preview-edit-version'),
              label: 'Modifier cette version',
              icon: Icons.edit_outlined,
              onPressed:
                  activePlatform == null
                      ? null
                      : () => _editVersion(activePlatform),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _PreviewSummary(post: post),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            key: const Key('preview-continue'),
            label: 'Continuer',
            icon: Icons.arrow_forward,
            onPressed:
                post.hasValidPlatformVariants ? () => _continue(post) : null,
          ),
        ],
      ),
    );
  }

  void _editVersion(SocialPlatform platform) {
    final callback = widget.onEditPlatform;
    if (callback != null) {
      callback(platform);
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(platform);
    } else {
      navigator.pushReplacementNamed(AppRoutes.postAdapt);
    }
  }

  void _continue(SocialPost post) {
    final callback = widget.onContinue;
    if (callback != null) {
      callback(post);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.postPublish);
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({required this.post});

  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    final count = post.platforms.length;
    final labels = _orderedPlatforms(
      post.platforms,
    ).map((platform) => platform.label).join(', ');
    return AppCard(
      semanticLabel:
          '$count réseaux prêts : $labels. Toutes les versions sont prêtes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$count réseau${count > 1 ? 'x' : ''} prêt${count > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const AppBadge(
                label: 'Toutes les versions sont prêtes',
                icon: Icons.check_circle_outline,
                tone: AppBadgeTone.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            labels,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

List<SocialPlatform> _orderedPlatforms(Set<SocialPlatform> selected) => [
  for (final platform in SocialPlatform.values)
    if (selected.contains(platform)) platform,
];
