import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_fields.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({
    this.onContinue,
    this.onImproveText,
    this.onGenerateCaption,
    this.onSuggestHashtags,
    super.key,
  });

  final ValueChanged<SocialPost>? onContinue;
  final VoidCallback? onImproveText;
  final VoidCallback? onGenerateCaption;
  final VoidCallback? onSuggestHashtags;

  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  late final TextEditingController _textController;
  var _isPicking = false;
  String? _mediaError;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(composerControllerProvider).caption,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(composerControllerProvider);
    final content = _contentFor(post.type);

    return FeatureScaffold(
      title: 'Créer une publication',
      subtitle: 'Étape 2 · Contenu source',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppBadge(
              label: content.typeLabel,
              icon: content.icon,
              tone: AppBadgeTone.info,
              semanticLabel: 'Type de publication : ${content.typeLabel}',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: content.heading, subtitle: content.guidance),
          if (post.type != PostType.text) ...[
            const SizedBox(height: AppSpacing.lg),
            _MediaComposer(
              post: post,
              isPicking: _isPicking,
              error: _mediaError,
              onPick: _pickMedia,
              onReplace: _replaceSingleMedia,
              onRemove: _removeMedia,
              onMove: _moveMedia,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            key: const Key('composer-text-field'),
            controller: _textController,
            label:
                post.type == PostType.text
                    ? 'Contenu de la publication'
                    : 'Légende (facultative)',
            hint:
                post.type == PostType.text
                    ? 'Écrivez votre publication…'
                    : 'Ajoutez un message pour accompagner votre média…',
            helperText:
                'Rédigez un contenu source. Les règles des plateformes seront appliquées plus tard.',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 8,
            onChanged: ref.read(composerControllerProvider.notifier).setCaption,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Coup de pouce IA',
            subtitle:
                'Actions facultatives, sans modifier votre contenu automatiquement.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppTertiaryButton(
                label: 'Améliorer le texte',
                icon: Icons.auto_awesome_outlined,
                onPressed: widget.onImproveText,
              ),
              AppTertiaryButton(
                label: 'Générer une légende',
                icon: Icons.edit_note_outlined,
                onPressed: widget.onGenerateCaption,
              ),
              AppTertiaryButton(
                label: 'Hashtags',
                icon: Icons.tag,
                onPressed: widget.onSuggestHashtags,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            key: const Key('composer-continue'),
            label: 'Continuer',
            icon: Icons.arrow_forward,
            onPressed:
                post.hasValidSourceContent && !_isPicking ? _continue : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _validationGuidance(post),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia() async {
    final post = ref.read(composerControllerProvider);
    final service = ref.read(mediaServiceProvider);
    _startPicking();
    try {
      switch (post.type) {
        case PostType.text:
          return;
        case PostType.image:
          final image = await service.pickImage();
          if (image == null) return;
          final path = await _processImage(image);
          ref.read(composerControllerProvider.notifier).setMedia([path]);
          return;
        case PostType.video:
          final video = await service.pickVideo();
          if (video == null) return;
          ref.read(composerControllerProvider.notifier).setMedia([video.path]);
          return;
        case PostType.carousel:
          final images = await service.pickImages();
          if (images.isEmpty) return;
          final paths = <String>[];
          for (final image in images) {
            paths.add(await _processImage(image));
          }
          ref.read(composerControllerProvider.notifier).addMedia(paths);
          return;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _mediaError =
              'Impossible d’ajouter ce média. Vérifiez son accès puis réessayez.';
        });
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _replaceSingleMedia() async {
    final post = ref.read(composerControllerProvider);
    final service = ref.read(mediaServiceProvider);
    _startPicking();
    try {
      final XFile? replacement = switch (post.type) {
        PostType.image => await service.pickImage(),
        PostType.video => await service.pickVideo(),
        PostType.carousel || PostType.text => null,
      };
      if (replacement == null) return;
      final path =
          post.type == PostType.image
              ? await _processImage(replacement)
              : replacement.path;
      ref.read(composerControllerProvider.notifier).setMedia([path]);
    } catch (_) {
      if (mounted) {
        setState(() {
          _mediaError =
              'Impossible de remplacer ce média. Réessayez dans un instant.';
        });
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<String> _processImage(XFile image) async {
    final compressed = await ref
        .read(mediaServiceProvider)
        .compressImage(image);
    return (compressed ?? image).path;
  }

  void _startPicking() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isPicking = true;
      _mediaError = null;
    });
  }

  void _removeMedia(int index) {
    ref.read(composerControllerProvider.notifier).removeMediaAt(index);
    if (_mediaError != null) setState(() => _mediaError = null);
  }

  void _moveMedia(int oldIndex, int newIndex) {
    ref.read(composerControllerProvider.notifier).moveMedia(oldIndex, newIndex);
  }

  void _continue() {
    FocusManager.instance.primaryFocus?.unfocus();
    final post = ref.read(composerControllerProvider);
    final onContinue = widget.onContinue;
    if (onContinue != null) {
      onContinue(post);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.postPlatforms);
  }
}

class _MediaComposer extends StatelessWidget {
  const _MediaComposer({
    required this.post,
    required this.isPicking,
    required this.error,
    required this.onPick,
    required this.onReplace,
    required this.onRemove,
    required this.onMove,
  });

  final SocialPost post;
  final bool isPicking;
  final String? error;
  final Future<void> Function() onPick;
  final Future<void> Function() onReplace;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onMove;

  @override
  Widget build(BuildContext context) {
    final paths = post.mediaPaths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paths.isEmpty)
          AppCard(
            semanticLabel: _emptyLabel(post.type),
            child: Column(
              children: [
                Icon(
                  _mediaIcon(post.type),
                  size: AppSizes.iconHero,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _emptyTitle(post.type),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _emptyDescription(post.type),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSecondaryButton(
                  key: const Key('composer-add-media'),
                  label: _addLabel(post.type),
                  icon: Icons.add_photo_alternate_outlined,
                  loading: isPicking,
                  onPressed: isPicking ? null : onPick,
                ),
              ],
            ),
          )
        else if (post.type == PostType.carousel)
          _CarouselMediaList(
            paths: paths,
            isPicking: isPicking,
            onAdd: onPick,
            onRemove: onRemove,
            onMove: onMove,
          )
        else
          _SingleMediaPreview(
            type: post.type,
            path: paths.first,
            isPicking: isPicking,
            onReplace: onReplace,
            onRemove: () => onRemove(0),
          ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            label: 'Erreur média : $error',
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(error!)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SingleMediaPreview extends StatelessWidget {
  const _SingleMediaPreview({
    required this.type,
    required this.path,
    required this.isPicking,
    required this.onReplace,
    required this.onRemove,
  });

  final PostType type;
  final String path;
  final bool isPicking;
  final Future<void> Function() onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isVideo = type == PostType.video;
    return AppCard(
      semanticLabel:
          '${isVideo ? 'Vidéo' : 'Photo'} sélectionnée : ${_fileName(path)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppRadius.control,
            child: SizedBox(
              height: AppSizes.networkImageHeight,
              child:
                  isVideo
                      ? _VideoPlaceholder(path: path)
                      : _LocalImagePreview(path: path),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _fileName(path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppSecondaryButton(
                key: const Key('composer-replace-media'),
                label: 'Remplacer',
                icon: Icons.swap_horiz,
                expand: false,
                loading: isPicking,
                onPressed: isPicking ? null : onReplace,
              ),
              AppTertiaryButton(
                label: 'Supprimer',
                icon: Icons.delete_outline,
                onPressed: isPicking ? null : onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarouselMediaList extends StatelessWidget {
  const _CarouselMediaList({
    required this.paths,
    required this.isPicking,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
  });

  final List<String> paths;
  final bool isPicking;
  final Future<void> Function() onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < paths.length; index++) ...[
          AppCard(
            semanticLabel:
                'Média ${index + 1} sur ${paths.length} : ${_fileName(paths[index])}',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final info = Row(
                  children: [
                    SizedBox.square(
                      dimension: AppSizes.avatarLarge,
                      child: ClipRRect(
                        borderRadius: AppRadius.control,
                        child: _LocalImagePreview(path: paths[index]),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Média ${index + 1}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _fileName(paths[index]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                final controls = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIconButton(
                      icon: Icons.arrow_upward,
                      tooltip: 'Déplacer le média ${index + 1} vers le haut',
                      onPressed:
                          index == 0 ? null : () => onMove(index, index - 1),
                    ),
                    AppIconButton(
                      icon: Icons.arrow_downward,
                      tooltip: 'Déplacer le média ${index + 1} vers le bas',
                      onPressed:
                          index == paths.length - 1
                              ? null
                              : () => onMove(index, index + 1),
                    ),
                    AppIconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Supprimer le média ${index + 1}',
                      onPressed: () => onRemove(index),
                    ),
                  ],
                );
                if (constraints.maxWidth < 340) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      info,
                      const SizedBox(height: AppSpacing.sm),
                      Align(alignment: Alignment.centerRight, child: controls),
                    ],
                  );
                }
                return Row(children: [Expanded(child: info), controls]);
              },
            ),
          ),
          if (index < paths.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          key: const Key('composer-add-media'),
          label: 'Ajouter des médias',
          icon: Icons.add_photo_alternate_outlined,
          loading: isPicking,
          onPressed: isPicking ? null : onAdd,
        ),
      ],
    );
  }
}

class _LocalImagePreview extends StatelessWidget {
  const _LocalImagePreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: AppSizes.iconHero,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Vidéo prête', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              _fileName(path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

_ComposerContent _contentFor(PostType type) => switch (type) {
  PostType.text => const _ComposerContent(
    typeLabel: 'Texte',
    icon: Icons.notes_outlined,
    heading: 'Rédigez votre contenu',
    guidance: 'Préparez le message source qui sera adapté plus tard.',
  ),
  PostType.image => const _ComposerContent(
    typeLabel: 'Photo',
    icon: Icons.image_outlined,
    heading: 'Composez votre publication photo',
    guidance: 'Ajoutez une photo, puis une légende si vous le souhaitez.',
  ),
  PostType.video => const _ComposerContent(
    typeLabel: 'Vidéo',
    icon: Icons.videocam_outlined,
    heading: 'Composez votre publication vidéo',
    guidance: 'Ajoutez une vidéo locale et son message source.',
  ),
  PostType.carousel => const _ComposerContent(
    typeLabel: 'Carrousel',
    icon: Icons.view_carousel_outlined,
    heading: 'Construisez votre carrousel',
    guidance: 'Ajoutez plusieurs médias et organisez leur ordre.',
  ),
};

String _validationGuidance(SocialPost post) => switch (post.type) {
  PostType.text =>
    post.caption.trim().isEmpty
        ? 'Ajoutez du texte pour continuer.'
        : 'Votre contenu source est prêt.',
  PostType.image =>
    post.mediaPaths.isEmpty
        ? 'Ajoutez une photo pour continuer.'
        : 'Votre photo est prête.',
  PostType.video =>
    post.mediaPaths.isEmpty
        ? 'Ajoutez une vidéo pour continuer.'
        : 'Votre vidéo est prête.',
  PostType.carousel =>
    post.mediaPaths.length < 2
        ? 'Ajoutez au moins deux médias pour créer un carrousel.'
        : 'Votre carrousel est prêt.',
};

IconData _mediaIcon(PostType type) => switch (type) {
  PostType.video => Icons.video_library_outlined,
  PostType.carousel => Icons.collections_outlined,
  PostType.image || PostType.text => Icons.add_photo_alternate_outlined,
};

String _emptyTitle(PostType type) => switch (type) {
  PostType.image => 'Ajoutez votre photo',
  PostType.video => 'Ajoutez votre vidéo',
  PostType.carousel => 'Ajoutez les médias du carrousel',
  PostType.text => '',
};

String _emptyDescription(PostType type) => switch (type) {
  PostType.image =>
    'Vous pourrez la remplacer ou la supprimer avant de continuer.',
  PostType.video =>
    'Le montage et les adaptations viendront dans une étape ultérieure.',
  PostType.carousel =>
    'L’ordre restera modifiable avant la sélection des réseaux.',
  PostType.text => '',
};

String _emptyLabel(PostType type) => switch (type) {
  PostType.image => 'Aucune photo sélectionnée',
  PostType.video => 'Aucune vidéo sélectionnée',
  PostType.carousel => 'Aucun média de carrousel sélectionné',
  PostType.text => '',
};

String _addLabel(PostType type) => switch (type) {
  PostType.image => 'Ajouter une photo',
  PostType.video => 'Ajouter une vidéo',
  PostType.carousel => 'Ajouter des médias',
  PostType.text => '',
};

String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;

class _ComposerContent {
  const _ComposerContent({
    required this.typeLabel,
    required this.icon,
    required this.heading,
    required this.guidance,
  });

  final String typeLabel;
  final IconData icon;
  final String heading;
  final String guidance;
}
