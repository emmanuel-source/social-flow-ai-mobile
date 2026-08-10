import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/post_preview_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  testWidgets('1 rendu initial', (tester) async {
    await _pumpPreview(tester);
    expect(find.byType(PostPreviewScreen), findsOneWidget);
    expect(find.text('Vérifiez chaque version'), findsOneWidget);
  });

  testWidgets('2 affiche uniquement les plateformes sélectionnées', (
    tester,
  ) async {
    await _pumpPreview(
      tester,
      platforms: const {SocialPlatform.instagram, SocialPlatform.linkedin},
    );
    expect(find.byKey(const Key('preview-instagram')), findsOneWidget);
    expect(find.byKey(const Key('preview-linkedin')), findsOneWidget);
    expect(find.byKey(const Key('preview-tiktok')), findsNothing);
  });

  testWidgets('3 annonce la plateforme active', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(tester);
    expect(find.bySemanticsLabel('Instagram, preview actif'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('4 change de plateforme sans modifier le Composer', (
    tester,
  ) async {
    final harness = await _pumpPreview(tester);
    final before = harness.post;
    await tester.tap(find.byKey(const Key('preview-tiktok')));
    await tester.pump();
    expect(find.text('TikTok'), findsWidgets);
    expect(identical(harness.post, before), isTrue);
  });

  testWidgets('5 affiche le compte cible partagé avec Platforms', (
    tester,
  ) async {
    await _pumpPreview(tester);
    expect(find.text('@socialflow'), findsOneWidget);
  });

  testWidgets('6 affiche la caption de la variante active', (tester) async {
    await _pumpPreview(
      tester,
      variants: const {SocialPlatform.instagram: 'Version Instagram'},
    );
    expect(find.text('Version Instagram'), findsOneWidget);
  });

  testWidgets('7 utilise réellement la variante personnalisée', (tester) async {
    await _pumpPreview(
      tester,
      sourceCaption: 'Source A',
      variants: const {SocialPlatform.instagram: 'Instagram B'},
    );
    expect(find.text('Instagram B'), findsOneWidget);
  });

  testWidgets('8 ne substitue pas la source à la variante personnalisée', (
    tester,
  ) async {
    await _pumpPreview(
      tester,
      sourceCaption: 'Source qui ne doit pas apparaître',
      variants: const {SocialPlatform.instagram: 'Version finale'},
    );
    expect(find.text('Version finale'), findsOneWidget);
    expect(find.text('Source qui ne doit pas apparaître'), findsNothing);
  });

  testWidgets('9 affiche le badge Original', (tester) async {
    await _pumpPreview(tester);
    expect(find.text('Original'), findsOneWidget);
  });

  testWidgets('10 affiche le badge Personnalisé', (tester) async {
    await _pumpPreview(
      tester,
      variants: const {SocialPlatform.instagram: 'Version différente'},
    );
    expect(find.text('Personnalisé'), findsOneWidget);
  });

  testWidgets('11 préserve l’indication Source modifiée', (tester) async {
    await _pumpPreview(
      tester,
      sourceCaption: 'Source A',
      variants: const {SocialPlatform.instagram: 'Version B'},
      updatedSourceCaption: 'Source C',
    );
    expect(find.text('Personnalisé · Source modifiée'), findsOneWidget);
  });

  testWidgets('12 Preview Text est centré sur la variante', (tester) async {
    await _pumpPreview(
      tester,
      type: PostType.text,
      variants: const {SocialPlatform.instagram: 'Texte final'},
    );
    expect(find.text('Texte'), findsOneWidget);
    expect(find.text('Texte final'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Image source')), findsNothing);
  });

  testWidgets('13 Preview Image annonce le PostType', (tester) async {
    await _pumpPreview(
      tester,
      type: PostType.image,
      mediaPaths: const ['C:/media/photo.jpg'],
    );
    expect(find.text('Photo'), findsOneWidget);
  });

  testWidgets('14 Preview Image utilise le média source ou son fallback', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      type: PostType.image,
      mediaPaths: const ['C:/media/photo.jpg'],
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Image source photo\.jpg')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('15 Preview Video annonce le PostType', (tester) async {
    await _pumpPreview(
      tester,
      type: PostType.video,
      mediaPaths: const ['C:/media/demo.mp4'],
    );
    expect(find.text('Vidéo'), findsOneWidget);
  });

  testWidgets('16 Preview Video reste statique et décrit le fichier', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      type: PostType.video,
      mediaPaths: const ['C:/media/demo.mp4'],
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'Aperçu vidéo statique, fichier demo\.mp4'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('17 Preview Carousel annonce le PostType', (tester) async {
    await _pumpPreview(
      tester,
      type: PostType.carousel,
      mediaPaths: _carouselMedia,
    );
    expect(find.text('Carrousel'), findsOneWidget);
  });

  testWidgets('18 Carousel respecte l’ordre des médias', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      type: PostType.carousel,
      mediaPaths: _carouselMedia,
    );
    expect(find.byKey(const Key('preview-carousel-media-0')), findsOneWidget);
    expect(
      find.bySemanticsLabel('Carrousel, média 1 sur 3, one.jpg'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('19 Carousel affiche son compteur', (tester) async {
    await _pumpPreview(
      tester,
      type: PostType.carousel,
      mediaPaths: _carouselMedia,
    );
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('20 Carousel navigue vers le média suivant', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      type: PostType.carousel,
      mediaPaths: _carouselMedia,
    );
    await _tapVisible(tester, find.byTooltip('Média suivant'));
    expect(
      find.bySemanticsLabel('Carrousel, média 2 sur 3, two.jpg'),
      findsOneWidget,
    );
    expect(find.text('2 / 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('21 Modifier transmet la plateforme active', (tester) async {
    SocialPlatform? requested;
    await _pumpPreview(
      tester,
      screen: PostPreviewScreen(
        onEditPlatform: (platform) => requested = platform,
      ),
    );
    await _tapVisible(tester, find.text('Modifier cette version'));
    expect(requested, SocialPlatform.instagram);
  });

  testWidgets('22 Modifier revient vers Adaptation', (tester) async {
    await _pumpNavigationHarness(tester);
    await tester.tap(find.text('Ouvrir Preview'));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Modifier cette version'));
    expect(find.text('Écran Adaptation'), findsOneWidget);
  });

  testWidgets('23 le retour conserve toutes les variantes', (tester) async {
    final harness = await _pumpNavigationHarness(tester);
    final variants = harness.post.platformVariants;
    await tester.tap(find.text('Ouvrir Preview'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(harness.post.platformVariants, variants);
  });

  testWidgets('24 CTA final est disponible lorsque tout est valide', (
    tester,
  ) async {
    await _pumpPreview(tester);
    await _reveal(tester, find.byKey(const Key('preview-continue')));
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('25 CTA final ouvre la route Publish préparatoire', (
    tester,
  ) async {
    await _pumpPreview(tester);
    await _reveal(tester, find.byKey(const Key('preview-continue')));
    _continueButton(tester).onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('SFA-PUB-006 préparatoire'), findsOneWidget);
  });

  testWidgets('26 transmet l’état complet à l’étape suivante', (tester) async {
    SocialPost? transmitted;
    await _pumpPreview(
      tester,
      variants: const {SocialPlatform.instagram: 'Version finale'},
      screen: PostPreviewScreen(onContinue: (post) => transmitted = post),
    );
    await _reveal(tester, find.byKey(const Key('preview-continue')));
    _continueButton(tester).onPressed!();
    expect(transmitted?.platforms, _defaultPlatforms);
    expect(
      transmitted?.platformVariants[SocialPlatform.instagram]?.caption,
      'Version finale',
    );
  });

  for (final entry in <(int, Size)>[
    (27, const Size(320, 700)),
    (28, const Size(390, 844)),
  ]) {
    testWidgets('${entry.$1} supporte ${entry.$2.width.toInt()} px', (
      tester,
    ) async {
      await _setViewport(tester, entry.$2);
      await _pumpPreview(tester, configureViewport: false);
      await _scrollToEnd(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('29 supporte cinq plateformes', (tester) async {
    await _pumpPreview(tester, platforms: _fivePlatforms);
    for (final platform in _fivePlatforms) {
      expect(find.byKey(Key('preview-${platform.name}')), findsOneWidget);
    }
  });

  testWidgets('30 supporte une caption très longue', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPreview(
      tester,
      configureViewport: false,
      sourceCaption: List.filled(140, 'contenu').join(' '),
    );
    await _scrollToEnd(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('31 supporte le texte agrandi à 130 %', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPreview(
      tester,
      configureViewport: false,
      textScaler: const TextScaler.linear(1.3),
      platforms: _fivePlatforms,
    );
    await _scrollToEnd(tester);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <(int, ThemeMode)>[
    (32, ThemeMode.light),
    (33, ThemeMode.dark),
  ]) {
    testWidgets('${entry.$1} supporte le thème ${entry.$2.name}', (
      tester,
    ) async {
      await _pumpPreview(tester, themeMode: entry.$2);
      final context = tester.element(find.byType(PostPreviewScreen));
      expect(
        Theme.of(context).brightness,
        entry.$2 == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    });
  }

  testWidgets('34 expose la plateforme aux technologies d’assistance', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(tester);
    expect(find.bySemanticsLabel('Instagram, preview actif'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('35 expose le compte cible aux technologies d’assistance', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(tester);
    expect(
      find.bySemanticsLabel(RegExp('Aperçu Instagram.*compte @socialflow')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('36 expose le média aux technologies d’assistance', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      type: PostType.image,
      mediaPaths: const ['C:/media/photo.jpg'],
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Image source photo\.jpg')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('37 expose l’état de variante textuellement', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPreview(
      tester,
      variants: const {SocialPlatform.instagram: 'Version adaptée'},
    );
    expect(
      find.bySemanticsLabel(RegExp(r'État de la variante : Personnalisé')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('38 reste sans overflow après navigation complète', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPreview(
      tester,
      configureViewport: false,
      type: PostType.carousel,
      mediaPaths: _carouselMedia,
      platforms: _fivePlatforms,
      sourceCaption: List.filled(80, 'aperçu').join(' '),
      textScaler: const TextScaler.linear(1.3),
    );
    await _tapVisible(tester, find.byTooltip('Média suivant'));
    await _scrollToEnd(tester);
    expect(tester.takeException(), isNull);
  });
}

const _defaultPlatforms = {
  SocialPlatform.instagram,
  SocialPlatform.tiktok,
  SocialPlatform.linkedin,
};
const _fivePlatforms = {
  SocialPlatform.instagram,
  SocialPlatform.facebook,
  SocialPlatform.tiktok,
  SocialPlatform.youtube,
  SocialPlatform.linkedin,
};
const _carouselMedia = [
  'C:/media/one.jpg',
  'C:/media/two.jpg',
  'C:/media/three.jpg',
];

Future<_PreviewHarness> _pumpPreview(
  WidgetTester tester, {
  PostType type = PostType.text,
  String sourceCaption = 'Source A',
  String? updatedSourceCaption,
  List<String> mediaPaths = const [],
  Set<SocialPlatform> platforms = _defaultPlatforms,
  Map<SocialPlatform, String> variants = const {},
  Widget screen = const PostPreviewScreen(),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool configureViewport = true,
}) async {
  if (configureViewport) await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final controller = container.read(composerControllerProvider.notifier);
  controller
    ..setType(type)
    ..setCaption(sourceCaption)
    ..setMedia(mediaPaths)
    ..setPlatforms(platforms);
  for (final entry in variants.entries) {
    controller.updatePlatformVariant(entry.key, entry.value);
  }
  if (updatedSourceCaption != null) {
    controller.setCaption(updatedSourceCaption);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
        routes: {
          AppRoutes.postPublish:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('SFA-PUB-006 préparatoire')),
              ),
          AppRoutes.postAdapt:
              (_) => const Scaffold(body: Text('Écran Adaptation')),
        },
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _PreviewHarness(container);
}

Future<_PreviewHarness> _pumpNavigationHarness(WidgetTester tester) async {
  await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final controller = container.read(composerControllerProvider.notifier);
  controller
    ..setCaption('Source A')
    ..setPlatforms(_defaultPlatforms)
    ..updatePlatformVariant(SocialPlatform.instagram, 'Instagram B');
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        routes: {
          AppRoutes.postPreview: (_) => const PostPreviewScreen(),
          AppRoutes.postPublish:
              (_) => const Scaffold(body: Text('SFA-PUB-006 préparatoire')),
        },
        home: Builder(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Écran Adaptation')),
                body: TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.postPreview),
                  child: const Text('Ouvrir Preview'),
                ),
              ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _PreviewHarness(container);
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0, -1600),
  );
  await tester.pumpAndSettle();
}

FilledButton _continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('preview-continue')),
        matching: find.byType(FilledButton),
      ),
    );

class _PreviewHarness {
  const _PreviewHarness(this.container);

  final ProviderContainer container;

  SocialPost get post => container.read(composerControllerProvider);
}
