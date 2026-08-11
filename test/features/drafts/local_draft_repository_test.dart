import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/drafts/data/repositories/local_draft_repository.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('draft_repository_test_');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>('drafts');
  });

  tearDown(() async {
    await Hive.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('creates, updates, orders and deletes independent drafts', () async {
    final timestamps = [
      DateTime.utc(2026, 8, 10, 8),
      DateTime.utc(2026, 8, 10, 9),
      DateTime.utc(2026, 8, 10, 10),
    ];
    final repository = LocalDraftRepository(
      box: box,
      now: () => timestamps.removeAt(0),
      createId: (now) => 'draft-${now.hour}',
    );
    final first = await repository.saveDraft(post: _post('Premier'));
    final second = await repository.saveDraft(post: _post('Deuxième'));

    final updated = await repository.saveDraft(
      post: _post('Premier modifié'),
      draftId: first.id,
    );
    final drafts = await repository.fetchDrafts();

    expect(drafts, hasLength(2));
    expect(drafts.map((draft) => draft.id), [first.id, second.id]);
    expect(updated.id, first.id);
    expect(updated.createdAt, first.createdAt);
    expect(updated.updatedAt.isAfter(first.updatedAt), isTrue);
    expect(drafts.first.sourceCaption, 'Premier modifié');
    expect(drafts.last.sourceCaption, 'Deuxième');
    expect(drafts.first.postType, PostType.image);
    expect(drafts.first.mediaPaths, ['photo.jpg']);
    expect(drafts.first.selectedPlatforms, {SocialPlatform.instagram});
    expect(
      drafts.first.platformVariants[SocialPlatform.instagram]?.caption,
      'Premier modifié Instagram',
    );

    await repository.deleteDraft(second.id);
    expect(await repository.fetchDrafts(), hasLength(1));
  });

  test('ignores records belonging to the publication simulator', () async {
    await box.put('post-1', {'status': 'published', 'caption': 'Publié'});
    final repository = LocalDraftRepository(box: box);

    expect(await repository.fetchDrafts(), isEmpty);
  });
}

SocialPost _post(String caption) => SocialPost(
  type: PostType.image,
  caption: caption,
  platforms: const {SocialPlatform.instagram},
  mediaPaths: const ['photo.jpg'],
  platformVariants: {
    SocialPlatform.instagram: PlatformPostVariant(
      platform: SocialPlatform.instagram,
      caption: '$caption Instagram',
      sourceCaptionSnapshot: caption,
    ),
  },
  mode: PublicationMode.draft,
);
