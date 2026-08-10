import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('starts with an empty recoverable draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final post = container.read(composerControllerProvider);

    expect(post.caption, isEmpty);
    expect(post.mediaPaths, isEmpty);
    expect(post.platforms, isEmpty);
    expect(post.mode, PublicationMode.draft);
  });

  test('keeps caption and media in the shared Composer state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);

    controller
      ..setType(PostType.carousel)
      ..setCaption('Contenu source')
      ..setMedia(['one.jpg', 'two.jpg']);

    final post = container.read(composerControllerProvider);
    expect(post.type, PostType.carousel);
    expect(post.caption, 'Contenu source');
    expect(post.mediaPaths, ['one.jpg', 'two.jpg']);
  });

  test('adds, replaces and removes media immutably', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);

    controller.addMedia(['one.jpg', 'two.jpg']);
    controller.replaceMediaAt(0, 'replacement.jpg');
    controller.removeMediaAt(1);

    expect(container.read(composerControllerProvider).mediaPaths, [
      'replacement.jpg',
    ]);
  });

  test('moves carousel media while preserving every item', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);
    controller.setMedia(['one.jpg', 'two.jpg', 'three.jpg']);

    controller.moveMedia(2, 0);

    expect(container.read(composerControllerProvider).mediaPaths, [
      'three.jpg',
      'one.jpg',
      'two.jpg',
    ]);
  });

  test('changing type clears incompatible media but keeps the source text', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);
    controller
      ..setCaption('Texte à conserver')
      ..setMedia(['photo.jpg'])
      ..setType(PostType.video);

    final post = container.read(composerControllerProvider);
    expect(post.type, PostType.video);
    expect(post.caption, 'Texte à conserver');
    expect(post.mediaPaths, isEmpty);
  });

  test('validates generic source content without platform limits', () {
    const cases = <SocialPost>[
      SocialPost(
        type: PostType.text,
        caption: 'Texte',
        platforms: {},
        mediaPaths: [],
        mode: PublicationMode.draft,
      ),
      SocialPost(
        type: PostType.image,
        caption: '',
        platforms: {},
        mediaPaths: ['photo.jpg'],
        mode: PublicationMode.draft,
      ),
      SocialPost(
        type: PostType.video,
        caption: '',
        platforms: {},
        mediaPaths: ['video.mp4'],
        mode: PublicationMode.draft,
      ),
      SocialPost(
        type: PostType.carousel,
        caption: '',
        platforms: {},
        mediaPaths: ['one.jpg', 'two.jpg'],
        mode: PublicationMode.draft,
      ),
    ];

    expect(cases.every((post) => post.hasValidSourceContent), isTrue);
  });

  test('rejects incomplete generic source content', () {
    const text = SocialPost(
      type: PostType.text,
      caption: '   ',
      platforms: {},
      mediaPaths: [],
      mode: PublicationMode.draft,
    );
    const carousel = SocialPost(
      type: PostType.carousel,
      caption: 'Optional caption',
      platforms: {},
      mediaPaths: ['only-one.jpg'],
      mode: PublicationMode.draft,
    );

    expect(text.hasValidSourceContent, isFalse);
    expect(carousel.hasValidSourceContent, isFalse);
  });

  test('ajoute et retire une plateforme', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);
    controller.togglePlatform(SocialPlatform.linkedin);
    expect(
      container.read(composerControllerProvider).platforms,
      contains(SocialPlatform.linkedin),
    );
    controller.togglePlatform(SocialPlatform.linkedin);
    expect(
      container.read(composerControllerProvider).platforms,
      isNot(contains(SocialPlatform.linkedin)),
    );
  });
}
