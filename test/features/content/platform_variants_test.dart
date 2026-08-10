import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('1 initialise une variante pour chaque plateforme sélectionnée', () {
    final harness = _harness(platforms: _targets);
    expect(harness.post.platformVariants.keys, containsAll(_targets));
  });

  test('2 copie initialement la caption source', () {
    final harness = _harness(caption: 'Source A', platforms: _targets);
    expect(
      harness.post.platformVariants.values.map((variant) => variant.caption),
      everyElement('Source A'),
    );
  });

  test('3 crée des entités de variantes indépendantes', () {
    final harness = _harness(platforms: _targets);
    expect(
      identical(
        harness.post.platformVariants[SocialPlatform.instagram],
        harness.post.platformVariants[SocialPlatform.linkedin],
      ),
      isFalse,
    );
  });

  test('4 modifie uniquement Instagram', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.updatePlatformVariant(SocialPlatform.instagram, 'B');
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'B',
    );
  });

  test('5 laisse LinkedIn inchangé après modification Instagram', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.updatePlatformVariant(SocialPlatform.instagram, 'B');
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'A',
    );
  });

  test('6 ne modifie jamais la source pendant une adaptation', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.updatePlatformVariant(SocialPlatform.instagram, 'B');
    expect(harness.post.caption, 'A');
  });

  test('7 conserve plusieurs adaptations distinctes', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller
      ..updatePlatformVariant(SocialPlatform.instagram, 'Instagram B')
      ..updatePlatformVariant(SocialPlatform.linkedin, 'LinkedIn C');
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'Instagram B',
    );
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'LinkedIn C',
    );
  });

  test('8 réinitialise Instagram depuis la source', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller
      ..updatePlatformVariant(SocialPlatform.instagram, 'B')
      ..resetPlatformVariant(SocialPlatform.instagram);
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'A',
    );
  });

  test('9 le reset Instagram ne touche pas LinkedIn', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller
      ..updatePlatformVariant(SocialPlatform.instagram, 'B')
      ..updatePlatformVariant(SocialPlatform.linkedin, 'C')
      ..resetPlatformVariant(SocialPlatform.instagram);
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'C',
    );
  });

  test('10 initialise une plateforme nouvellement ajoutée', () {
    final harness = _harness(
      caption: 'A',
      platforms: const {SocialPlatform.instagram},
    );
    harness.controller.setPlatforms(_targets);
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'A',
    );
  });

  test('11 masque une plateforme retirée du workflow actif', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.setPlatforms(const {SocialPlatform.instagram});
    expect(
      harness.post.activePlatformVariants,
      isNot(contains(SocialPlatform.linkedin)),
    );
  });

  test('12 conserve temporairement la variante d’une plateforme retirée', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller
      ..updatePlatformVariant(SocialPlatform.linkedin, 'C')
      ..setPlatforms(const {SocialPlatform.instagram});
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'C',
    );
  });

  test('13 une plateforme réellement nouvelle part de la source', () {
    final harness = _harness(
      caption: 'Source actuelle',
      platforms: const {SocialPlatform.instagram},
    );
    harness.controller.setPlatforms(const {
      SocialPlatform.instagram,
      SocialPlatform.tiktok,
    });
    expect(
      harness.post.platformVariants[SocialPlatform.tiktok]?.caption,
      'Source actuelle',
    );
  });

  test('14 la source peut être modifiée après initialisation', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.setCaption('C');
    expect(harness.post.caption, 'C');
  });

  test('15 une variante originale suit la nouvelle source', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller.setCaption('C');
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'C',
    );
  });

  test('16 une variante personnalisée survit au changement de source', () {
    final harness = _harness(caption: 'A', platforms: _targets);
    harness.controller
      ..updatePlatformVariant(SocialPlatform.linkedin, 'B')
      ..setCaption('C');
    final variant = harness.post.platformVariants[SocialPlatform.linkedin]!;
    expect(variant.caption, 'B');
    expect(variant.sourceChangedSinceLastSync('C'), isTrue);
  });

  test('17 les variantes partagent les références média du post', () {
    final harness = _harness(
      type: PostType.image,
      caption: 'A',
      mediaPaths: const ['photo.jpg'],
      platforms: _targets,
    );
    harness.controller.updatePlatformVariant(SocialPlatform.instagram, 'B');
    expect(harness.post.mediaPaths, ['photo.jpg']);
  });

  test('18 l’ordre du carrousel reste commun et intact', () {
    final harness = _harness(
      type: PostType.carousel,
      caption: 'A',
      mediaPaths: const ['one.jpg', 'two.jpg', 'three.jpg'],
      platforms: _targets,
    );
    harness.controller.updatePlatformVariant(SocialPlatform.linkedin, 'C');
    expect(harness.post.mediaPaths, ['one.jpg', 'two.jpg', 'three.jpg']);
  });

  test('19 les collections de variantes et plateformes sont immuables', () {
    final harness = _harness(platforms: _targets);
    expect(
      () =>
          harness.post.platformVariants[SocialPlatform
              .tiktok] = PlatformPostVariant.fromSource(
            platform: SocialPlatform.tiktok,
            sourceCaption: 'X',
          ),
      throwsUnsupportedError,
    );
    expect(
      () => harness.post.platforms.add(SocialPlatform.tiktok),
      throwsUnsupportedError,
    );
  });
}

const _targets = {SocialPlatform.instagram, SocialPlatform.linkedin};

_ControllerHarness _harness({
  PostType type = PostType.text,
  String caption = 'Source',
  List<String> mediaPaths = const [],
  Set<SocialPlatform> platforms = const {},
}) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final controller = container.read(composerControllerProvider.notifier);
  controller
    ..setType(type)
    ..setCaption(caption)
    ..setMedia(mediaPaths)
    ..setPlatforms(platforms)
    ..initializePlatformVariants();
  return _ControllerHarness(container, controller);
}

class _ControllerHarness {
  const _ControllerHarness(this.container, this.controller);

  final ProviderContainer container;
  final ComposerController controller;

  SocialPost get post => container.read(composerControllerProvider);
}
