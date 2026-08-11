import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/drafts/domain/entities/draft.dart';
import 'package:socialflow_ai/features/drafts/domain/repositories/draft_repository.dart';
import 'package:socialflow_ai/features/drafts/draft_providers.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('restores the complete Composer and updates the same draft', () async {
    final repository = _MemoryDraftRepository();
    final container = ProviderContainer(
      overrides: [draftRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);
    final existing = Draft(
      id: 'draft-existing',
      postType: PostType.carousel,
      sourceCaption: 'Source restaurée',
      mediaPaths: const ['missing-one.jpg', 'missing-two.jpg'],
      selectedPlatforms: const {
        SocialPlatform.instagram,
        SocialPlatform.linkedin,
      },
      platformVariants: const {
        SocialPlatform.instagram: PlatformPostVariant(
          platform: SocialPlatform.instagram,
          caption: 'Instagram restauré',
          sourceCaptionSnapshot: 'Source restaurée',
        ),
        SocialPlatform.linkedin: PlatformPostVariant(
          platform: SocialPlatform.linkedin,
          caption: 'LinkedIn restauré',
          sourceCaptionSnapshot: 'Source restaurée',
        ),
      },
      createdAt: DateTime.utc(2026, 8, 10),
      updatedAt: DateTime.utc(2026, 8, 10),
    );

    controller.restoreDraft(existing);
    final restored = container.read(composerControllerProvider);
    expect(controller.activeDraftId, existing.id);
    expect(restored.type, PostType.carousel);
    expect(restored.caption, existing.sourceCaption);
    expect(restored.mediaPaths, existing.mediaPaths);
    expect(restored.platforms, existing.selectedPlatforms);
    expect(restored.platformVariants.keys, existing.platformVariants.keys);

    controller.setCaption('Source mise à jour');
    final saved = await controller.saveDraft();
    expect(saved.id, existing.id);
    expect(repository.lastDraftId, existing.id);
    expect(repository.items, hasLength(1));
    expect(repository.items.single.sourceCaption, 'Source mise à jour');
  });

  test('two new Composer sessions create two independent drafts', () async {
    final repository = _MemoryDraftRepository();
    final container = ProviderContainer(
      overrides: [draftRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);

    controller
      ..startNew(PostType.text)
      ..setCaption('Premier');
    final first = await controller.saveDraft();
    controller
      ..startNew(PostType.text)
      ..setCaption('Deuxième');
    final second = await controller.saveDraft();

    expect(first.id, isNot(second.id));
    expect(repository.items, hasLength(2));
  });
}

class _MemoryDraftRepository implements DraftRepository {
  final items = <Draft>[];
  String? lastDraftId;
  var _counter = 0;

  @override
  Future<List<Draft>> fetchDrafts() async => List.of(items);

  @override
  Future<Draft> saveDraft({required SocialPost post, String? draftId}) async {
    lastDraftId = draftId;
    final id = draftId ?? 'draft-${++_counter}';
    final index = items.indexWhere((draft) => draft.id == id);
    final timestamp = DateTime.utc(2026, 8, 11, 10, _counter);
    final draft = Draft(
      id: id,
      postType: post.type,
      sourceCaption: post.caption,
      mediaPaths: post.mediaPaths,
      selectedPlatforms: post.platforms,
      platformVariants: post.platformVariants,
      createdAt: index == -1 ? timestamp : items[index].createdAt,
      updatedAt: timestamp,
    );
    if (index == -1) {
      items.add(draft);
    } else {
      items[index] = draft;
    }
    return draft;
  }

  @override
  Future<void> deleteDraft(String id) async {
    items.removeWhere((draft) => draft.id == id);
  }
}
