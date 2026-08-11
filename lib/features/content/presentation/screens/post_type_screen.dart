import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class PostTypeScreen extends ConsumerStatefulWidget {
  const PostTypeScreen({this.onContinue, super.key});

  final ValueChanged<PostType>? onContinue;

  @override
  ConsumerState<PostTypeScreen> createState() => _PostTypeScreenState();
}

class _PostTypeScreenState extends ConsumerState<PostTypeScreen> {
  PostType? _selectedType;

  static const _options = <_PostTypeOption>[
    _PostTypeOption(
      type: PostType.text,
      icon: Icons.notes_outlined,
      title: 'Texte',
      description: 'Partagez une idée, une actualité ou un conseil.',
    ),
    _PostTypeOption(
      type: PostType.image,
      icon: Icons.image_outlined,
      title: 'Photo',
      description: 'Publiez une image accompagnée de votre message.',
    ),
    _PostTypeOption(
      type: PostType.video,
      icon: Icons.videocam_outlined,
      title: 'Vidéo',
      description: 'Créez une vidéo adaptable à plusieurs plateformes.',
    ),
    _PostTypeOption(
      type: PostType.carousel,
      icon: Icons.view_carousel_outlined,
      title: 'Carrousel',
      description: 'Présentez plusieurs images dans une même publication.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Créer une publication',
      subtitle: 'Étape 1 · Type de contenu',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AppBadge(
              label: 'Étape 1',
              icon: Icons.auto_awesome_outlined,
              tone: AppBadgeTone.info,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: const SectionHeader(
              title: 'Quel type de contenu souhaitez-vous créer ?',
              subtitle:
                  'Choisissez une intention. Les plateformes seront sélectionnées plus tard.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < _options.length; index++) ...[
            _PostTypeCard(
              option: _options[index],
              selected: _selectedType == _options[index].type,
              onTap: () => setState(() => _selectedType = _options[index].type),
            ),
            if (index < _options.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            key: const Key('post-type-continue'),
            label: 'Continuer',
            icon: Icons.arrow_forward,
            onPressed: _selectedType == null ? null : _continue,
          ),
        ],
      ),
    );
  }

  void _continue() {
    final selectedType = _selectedType;
    if (selectedType == null) return;

    ref.read(composerControllerProvider.notifier).startNew(selectedType);
    final onContinue = widget.onContinue;
    if (onContinue != null) {
      onContinue(selectedType);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.postMedia);
  }
}

class _PostTypeCard extends StatelessWidget {
  const _PostTypeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _PostTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      key: Key('post-type-${option.type.name}'),
      selected: selected,
      child: AppCard(
        onTap: onTap,
        elevated: selected,
        semanticLabel:
            '${option.title}. ${option.description}${selected ? ' Sélectionné.' : ''}',
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color:
                    selected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                borderRadius: AppRadius.control,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  option.icon,
                  color:
                      selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (selected)
              const AppBadge(
                label: 'Sélectionné',
                icon: Icons.check,
                tone: AppBadgeTone.success,
              )
            else
              Icon(Icons.radio_button_unchecked, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class _PostTypeOption {
  const _PostTypeOption({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
  });

  final PostType type;
  final IconData icon;
  final String title;
  final String description;
}
