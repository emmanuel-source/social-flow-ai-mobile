import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../application/drafts_controller.dart';
import '../../domain/entities/draft.dart';

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({this.onOpen, super.key});

  final ValueChanged<Draft>? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsControllerProvider);
    final controller = ref.read(draftsControllerProvider.notifier);

    return FeatureScaffold(
      title: 'Brouillons',
      subtitle: 'Enregistrés sur cet appareil',
      body: drafts.when(
        loading:
            () => const AppLoader(
              key: Key('drafts-loading'),
              label: 'Chargement des brouillons',
            ),
        error:
            (error, stackTrace) => AppErrorState(
              key: const Key('drafts-error'),
              title: 'Brouillons indisponibles',
              message:
                  'Impossible de lire les brouillons enregistrés sur cet appareil.',
              onRetry: controller.reload,
            ),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              key: Key('drafts-empty'),
              title: 'Aucun brouillon',
              message:
                  'Enregistrez une création depuis le Composer pour la retrouver ici.',
              icon: Icons.edit_note_outlined,
            );
          }
          return Column(
            key: const Key('drafts-list'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  '${items.length} brouillon${items.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < items.length; index++) ...[
                _DraftCard(
                  draft: items[index],
                  onOpen: () => _open(context, items[index]),
                  onDelete:
                      () => _confirmDelete(context, controller, items[index]),
                ),
                if (index < items.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Draft draft) {
    final callback = onOpen;
    if (callback != null) {
      callback(draft);
    } else {
      Navigator.pop(context, draft);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DraftsController controller,
    Draft draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Supprimer ce brouillon ?'),
            content: const Text(
              'Cette action supprimera uniquement le brouillon local.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                key: const Key('confirm-delete-draft'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirmed == true) await controller.delete(draft.id);
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.onOpen,
    required this.onDelete,
  });

  final Draft draft;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final missingMedia = _missingMediaCount(draft.mediaPaths);
    final caption = draft.sourceCaption.trim();
    return AppCard(
      key: Key('draft-card-${draft.id}'),
      onTap: onOpen,
      semanticLabel:
          'Reprendre le brouillon ${_postTypeLabel(draft)}, modifié ${_formattedDate(draft.updatedAt)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: AppRadius.control,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(
                    _postTypeIcon(draft),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: AppSizes.iconLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _postTypeLabel(draft),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Modifié ${_formattedDate(draft.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                key: Key('delete-draft-${draft.id}'),
                icon: Icons.delete_outline,
                tooltip: 'Supprimer ce brouillon',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            caption.isEmpty ? 'Sans texte' : caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(
                label:
                    '${draft.mediaPaths.length} média${draft.mediaPaths.length > 1 ? 's' : ''}',
                icon: Icons.perm_media_outlined,
              ),
              for (final platform in draft.selectedPlatforms)
                AppBadge(label: platform.label),
            ],
          ),
          if (missingMedia > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Semantics(
              liveRegion: true,
              label:
                  '$missingMedia média${missingMedia > 1 ? 's' : ''} local${missingMedia > 1 ? 'aux' : ''} indisponible${missingMedia > 1 ? 's' : ''}',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.error,
                    size: AppSizes.iconMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$missingMedia média${missingMedia > 1 ? 's' : ''} à remplacer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

int _missingMediaCount(List<String> paths) {
  var count = 0;
  for (final path in paths) {
    try {
      if (!File(path).existsSync()) count++;
    } on FileSystemException {
      count++;
    }
  }
  return count;
}

String _postTypeLabel(Draft draft) => switch (draft.postType.name) {
  'text' => 'Publication texte',
  'image' => 'Publication photo',
  'video' => 'Publication vidéo',
  'carousel' => 'Carrousel',
  _ => 'Publication',
};

IconData _postTypeIcon(Draft draft) => switch (draft.postType.name) {
  'text' => Icons.notes_outlined,
  'image' => Icons.image_outlined,
  'video' => Icons.videocam_outlined,
  'carousel' => Icons.view_carousel_outlined,
  _ => Icons.edit_note_outlined,
};

String _formattedDate(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int part) => part.toString().padLeft(2, '0');
  return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} à ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
