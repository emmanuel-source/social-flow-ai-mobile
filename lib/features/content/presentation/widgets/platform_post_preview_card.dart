import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/social_network_card.dart';
import '../../domain/entities/platform_post_variant.dart';
import '../../domain/entities/social_post.dart';
import '../models/demo_social_account.dart';

class PlatformPostPreviewCard extends StatefulWidget {
  const PlatformPostPreviewCard({
    required this.post,
    required this.variant,
    required this.account,
    super.key,
  });

  final SocialPost post;
  final PlatformPostVariant variant;
  final DemoSocialAccount account;

  @override
  State<PlatformPostPreviewCard> createState() =>
      _PlatformPostPreviewCardState();
}

class _PlatformPostPreviewCardState extends State<PlatformPostPreviewCard> {
  var _mediaIndex = 0;

  @override
  void didUpdateWidget(covariant PlatformPostPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.mediaPaths.length != widget.post.mediaPaths.length ||
        _mediaIndex >= widget.post.mediaPaths.length) {
      _mediaIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final variant = widget.variant;
    final customized = !variant.matchesSource(post.caption);
    final sourceChanged =
        customized && variant.sourceChangedSinceLastSync(post.caption);
    final status =
        customized
            ? sourceChanged
                ? 'Personnalisé · Source modifiée'
                : 'Personnalisé'
            : 'Original';
    final typeLabel = _typeLabel(post.type);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          'Aperçu ${widget.account.platform.label}, compte ${widget.account.accountLabel}, type $typeLabel, état $status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SocialNetworkCard(
            platform: widget.account.platform,
            accountLabel: widget.account.accountLabel,
            connected: widget.account.connected,
            selected: true,
            compact: true,
            onTap: null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppBadge(
                      label: typeLabel,
                      icon: _typeIcon(post.type),
                      tone: AppBadgeTone.neutral,
                      semanticLabel: 'Type de contenu : $typeLabel',
                    ),
                    AppBadge(
                      label: status,
                      icon: customized ? Icons.edit_outlined : Icons.sync,
                      tone:
                          customized ? AppBadgeTone.info : AppBadgeTone.success,
                      semanticLabel: 'État de la variante : $status',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildMedia(context),
                if (post.type != PostType.text)
                  const SizedBox(height: AppSpacing.md),
                Semantics(
                  label:
                      variant.caption.trim().isEmpty
                          ? 'Caption finale vide'
                          : 'Caption finale : ${variant.caption}',
                  child: Text(
                    variant.caption.trim().isEmpty
                        ? 'Aucune caption'
                        : variant.caption,
                    style:
                        post.type == PostType.text
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final media = widget.post.mediaPaths;
    if (widget.post.type != PostType.text && media.isEmpty) {
      return const _MediaFallback(
        icon: Icons.broken_image_outlined,
        label: 'Média source manquant',
        semanticLabel: 'Avertissement : média source manquant',
      );
    }
    return switch (widget.post.type) {
      PostType.text => const SizedBox.shrink(),
      PostType.image => _ImagePreview(path: media.first),
      PostType.video => _VideoPreview(path: media.first),
      PostType.carousel => _buildCarousel(context),
    };
  }

  Widget _buildCarousel(BuildContext context) {
    final media = widget.post.mediaPaths;
    final path = media[_mediaIndex];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          'Carrousel, média ${_mediaIndex + 1} sur ${media.length}, ${_fileName(path)}',
      child: Column(
        children: [
          _ImagePreview(
            key: Key('preview-carousel-media-$_mediaIndex'),
            path: path,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIconButton(
                icon: Icons.chevron_left,
                tooltip: 'Média précédent',
                onPressed:
                    _mediaIndex == 0
                        ? null
                        : () => setState(() => _mediaIndex--),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                key: const Key('preview-carousel-counter'),
                label: '${_mediaIndex + 1} / ${media.length}',
                semanticLabel: 'Média ${_mediaIndex + 1} sur ${media.length}',
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconButton(
                icon: Icons.chevron_right,
                tooltip: 'Média suivant',
                onPressed:
                    _mediaIndex == media.length - 1
                        ? null
                        : () => setState(() => _mediaIndex++),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    final fallback = _MediaFallback(
      icon: Icons.image_outlined,
      label: _fileName(path),
      semanticLabel: 'Aperçu image indisponible, fichier ${_fileName(path)}',
    );
    final image =
        kIsWeb
            ? Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
            : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            );
    return Semantics(
      image: true,
      label: 'Image source ${_fileName(path)}',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: AppRadius.control,
          child: SizedBox(
            height: AppSizes.networkImageHeight,
            width: double.infinity,
            child: image,
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => _MediaFallback(
    icon: Icons.play_circle_outline,
    label: _fileName(path),
    semanticLabel: 'Aperçu vidéo statique, fichier ${_fileName(path)}',
  );
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: semanticLabel,
    child: ExcludeSemantics(
      child: Container(
        height: AppSizes.networkImageHeight,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.control,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconHero),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

String _typeLabel(PostType type) => switch (type) {
  PostType.text => 'Texte',
  PostType.image => 'Photo',
  PostType.video => 'Vidéo',
  PostType.carousel => 'Carrousel',
};

IconData _typeIcon(PostType type) => switch (type) {
  PostType.text => Icons.notes_outlined,
  PostType.image => Icons.image_outlined,
  PostType.video => Icons.videocam_outlined,
  PostType.carousel => Icons.view_carousel_outlined,
};

String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;
