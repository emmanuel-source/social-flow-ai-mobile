import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/drafts/data/models/draft_record.dart';
import 'package:socialflow_ai/features/drafts/domain/entities/draft.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('serializes and restores every draft field', () {
    final draft = Draft(
      id: 'draft-serialization',
      postType: PostType.carousel,
      sourceCaption: 'Contenu source',
      mediaPaths: ['one.jpg', 'two.jpg'],
      selectedPlatforms: {SocialPlatform.instagram, SocialPlatform.linkedin},
      platformVariants: {
        SocialPlatform.instagram: const PlatformPostVariant(
          platform: SocialPlatform.instagram,
          caption: 'Version Instagram',
          sourceCaptionSnapshot: 'Contenu source',
        ),
        SocialPlatform.linkedin: const PlatformPostVariant(
          platform: SocialPlatform.linkedin,
          caption: 'Version LinkedIn',
          sourceCaptionSnapshot: 'Ancienne source',
        ),
      },
      createdAt: DateTime.utc(2026, 8, 10, 8),
      updatedAt: DateTime.utc(2026, 8, 11, 9, 30),
    );

    final restored = DraftRecord.fromMap(DraftRecord.toMap(draft));

    expect(restored.id, draft.id);
    expect(restored.postType, PostType.carousel);
    expect(restored.sourceCaption, 'Contenu source');
    expect(restored.mediaPaths, ['one.jpg', 'two.jpg']);
    expect(restored.selectedPlatforms, draft.selectedPlatforms);
    expect(restored.platformVariants.keys, draft.platformVariants.keys);
    expect(
      restored.platformVariants[SocialPlatform.instagram]?.caption,
      'Version Instagram',
    );
    expect(
      restored.platformVariants[SocialPlatform.linkedin]?.sourceCaptionSnapshot,
      'Ancienne source',
    );
    expect(restored.createdAt, draft.createdAt);
    expect(restored.updatedAt, draft.updatedAt);
  });

  test('rejects unknown PostType and platform values', () {
    final map = DraftRecord.toMap(
      Draft(
        id: 'invalid',
        postType: PostType.text,
        sourceCaption: '',
        mediaPaths: const [],
        selectedPlatforms: const {},
        platformVariants: const {},
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    expect(
      () => DraftRecord.fromMap({...map, 'postType': 'unknown'}),
      throwsFormatException,
    );
    expect(
      () => DraftRecord.fromMap({
        ...map,
        'selectedPlatforms': ['unknown'],
      }),
      throwsFormatException,
    );
  });
}
