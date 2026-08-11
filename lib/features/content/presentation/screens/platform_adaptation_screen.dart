import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_fields.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/social_platform_visuals.dart';
import '../../domain/entities/platform_post_variant.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class PlatformAdaptationScreen extends ConsumerStatefulWidget {
  const PlatformAdaptationScreen({this.onContinue, this.onAiAdapt, super.key});

  final ValueChanged<SocialPost>? onContinue;
  final ValueChanged<SocialPlatform>? onAiAdapt;

  @override
  ConsumerState<PlatformAdaptationScreen> createState() =>
      _PlatformAdaptationScreenState();
}

class _PlatformAdaptationScreenState
    extends ConsumerState<PlatformAdaptationScreen> {
  late final TextEditingController _captionController;
  SocialPlatform? _activePlatform;

  @override
  void initState() {
    super.initState();
    final post = ref.read(composerControllerProvider);
    final platforms = _orderedPlatforms(post.platforms);
    _activePlatform = platforms.isEmpty ? null : platforms.first;
    _captionController = TextEditingController(
      text: _activeVariant(post)?.caption ?? post.caption,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(composerControllerProvider.notifier)
            .initializePlatformVariants();
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
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
      title: 'Adapter votre contenu',
      subtitle: 'Étape 4 · Versions par réseau',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Personnalisez chaque version',
            subtitle:
                'Votre contenu source reste intact pendant vos adaptations.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _SourceSummary(post: post),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Plateformes sélectionnées',
            subtitle: 'Choisissez la version que vous souhaitez modifier.',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (platforms.isEmpty)
            const AppCard(
              child: Text(
                'Aucune plateforme sélectionnée. Revenez à l’étape précédente pour choisir vos réseaux.',
              ),
            )
          else
            SingleChildScrollView(
              key: const Key('adaptation-platform-selector'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < platforms.length; index++) ...[
                    SocialPlatformChip(
                      key: Key('adaptation-${platforms[index].name}'),
                      platform: platforms[index],
                      selected: platforms[index] == activePlatform,
                      semanticLabel:
                          '${platforms[index].label}, ${platforms[index] == activePlatform ? 'plateforme active' : 'plateforme inactive'}',
                      onSelected:
                          (_) => _selectPlatform(platforms[index], post),
                    ),
                    if (index < platforms.length - 1)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          if (activePlatform != null && variant != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildEditor(context, post, activePlatform, variant),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            key: const Key('adaptation-continue'),
            label: 'Continuer vers l’aperçu',
            icon: Icons.arrow_forward,
            onPressed:
                post.hasValidPlatformVariants ? () => _continue(post) : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _validationMessage(post),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    SocialPost post,
    SocialPlatform platform,
    PlatformPostVariant variant,
  ) {
    final customized = !variant.matchesSource(post.caption);
    final sourceChanged =
        customized && variant.sourceChangedSinceLastSync(post.caption);
    final status =
        customized
            ? sourceChanged
                ? 'Personnalisé · Source modifiée'
                : 'Personnalisé'
            : 'Original';

    return Semantics(
      container: true,
      label: 'Version ${platform.label}, état $status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SocialPlatformIcon(platform: platform),
              Text(
                'Version ${platform.label}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppBadge(
                key: const Key('adaptation-status'),
                label: status,
                icon: customized ? Icons.edit_outlined : Icons.sync,
                tone: customized ? AppBadgeTone.info : AppBadgeTone.success,
                semanticLabel: 'État de la version : $status',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('adaptation-caption-field'),
            controller: _captionController,
            label: 'Texte pour ${platform.label}',
            hint: 'Personnalisez le texte pour ${platform.label}…',
            helperText:
                'Les hashtags restent dans ce texte. Aucune limite spécifique n’est appliquée.',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 8,
            onChanged:
                (value) => ref
                    .read(composerControllerProvider.notifier)
                    .updatePlatformVariant(platform, value),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppTertiaryButton(
                label: 'Réinitialiser depuis la source',
                icon: Icons.restart_alt,
                onPressed: customized ? () => _resetPlatform(platform) : null,
              ),
              AppSecondaryButton(
                label:
                    widget.onAiAdapt == null
                        ? 'Adapter avec Social Flow AI · Bientôt'
                        : 'Adapter avec Social Flow AI',
                icon: Icons.auto_awesome_outlined,
                expand: false,
                onPressed:
                    widget.onAiAdapt == null
                        ? null
                        : () => widget.onAiAdapt!(platform),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPlatform(SocialPlatform platform, SocialPost post) {
    setState(() {
      _activePlatform = platform;
      _captionController.value = TextEditingValue(
        text: post.platformVariants[platform]?.caption ?? post.caption,
        selection: TextSelection.collapsed(
          offset:
              (post.platformVariants[platform]?.caption ?? post.caption).length,
        ),
      );
    });
  }

  void _resetPlatform(SocialPlatform platform) {
    ref
        .read(composerControllerProvider.notifier)
        .resetPlatformVariant(platform);
    final source = ref.read(composerControllerProvider).caption;
    _captionController.value = TextEditingValue(
      text: source,
      selection: TextSelection.collapsed(offset: source.length),
    );
  }

  Future<void> _continue(SocialPost post) async {
    final callback = widget.onContinue;
    if (callback != null) {
      callback(post);
      return;
    }
    final platform = await Navigator.pushNamed(context, AppRoutes.postPreview);
    if (!mounted || platform is! SocialPlatform) return;
    final latestPost = ref.read(composerControllerProvider);
    if (latestPost.platforms.contains(platform)) {
      _selectPlatform(platform, latestPost);
    }
  }

  PlatformPostVariant? _activeVariant(SocialPost post) {
    final platform = _activePlatform;
    return platform == null ? null : post.platformVariants[platform];
  }
}

class _SourceSummary extends StatelessWidget {
  const _SourceSummary({required this.post});

  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    final sourceText =
        post.caption.trim().isEmpty ? 'Aucun texte source' : post.caption;
    final mediaLabel = switch (post.type) {
      PostType.text => 'Publication texte',
      PostType.image => '1 photo source',
      PostType.video => '1 vidéo source',
      PostType.carousel => '${post.mediaPaths.length} médias source',
    };

    return AppCard(
      semanticLabel: 'Contenu source, $mediaLabel, $sourceText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Contenu source',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              AppBadge(
                label: mediaLabel,
                icon: _postTypeIcon(post.type),
                tone: AppBadgeTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sourceText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
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

String _validationMessage(SocialPost post) {
  if (post.platforms.isEmpty) {
    return 'Sélectionnez au moins une plateforme pour continuer.';
  }
  if (!post.hasValidSourceContent) {
    return 'Le contenu source doit être valide avant de continuer.';
  }
  if (!post.hasValidPlatformVariants) {
    return 'Chaque publication texte doit conserver une version non vide.';
  }
  return 'Les variantes sont prêtes pour la prochaine étape.';
}

IconData _postTypeIcon(PostType type) => switch (type) {
  PostType.text => Icons.notes_outlined,
  PostType.image => Icons.image_outlined,
  PostType.video => Icons.videocam_outlined,
  PostType.carousel => Icons.view_carousel_outlined,
};
