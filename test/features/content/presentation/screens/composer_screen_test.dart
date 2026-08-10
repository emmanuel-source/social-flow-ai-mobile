import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/app/app_shell.dart';
import 'package:socialflow_ai/core/media/media_service.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/composer_screen.dart';
import 'package:socialflow_ai/features/content/presentation/screens/create_hub_screen.dart';
import 'package:socialflow_ai/features/content/presentation/screens/post_type_screen.dart';
import 'package:socialflow_ai/shared/providers/core_providers.dart';

void main() {
  testWidgets('renders the Composer hierarchy', (tester) async {
    await _pumpComposer(tester, type: PostType.text);

    expect(find.text('Créer une publication'), findsOneWidget);
    expect(find.text('Étape 2 · Contenu source'), findsOneWidget);
    expect(find.text('Rédigez votre contenu'), findsOneWidget);
    expect(find.byKey(const Key('composer-text-field')), findsOneWidget);
  });

  for (final variant in <(PostType, String, String)>[
    (PostType.text, 'Texte', 'Rédigez votre contenu'),
    (PostType.image, 'Photo', 'Composez votre publication photo'),
    (PostType.video, 'Vidéo', 'Composez votre publication vidéo'),
    (PostType.carousel, 'Carrousel', 'Construisez votre carrousel'),
  ]) {
    testWidgets('adapts the Composer to ${variant.$1.name}', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpComposer(tester, type: variant.$1);

      expect(find.text(variant.$2), findsOneWidget);
      expect(find.text(variant.$3), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Type de publication : ${variant.$2}')),
        findsWidgets,
      );
      semantics.dispose();
    });
  }

  testWidgets('text starts invalid and without a media area', (tester) async {
    await _pumpComposer(tester, type: PostType.text);

    expect(find.byKey(const Key('composer-add-media')), findsNothing);
    expect(find.text('Ajoutez du texte pour continuer.'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('text entry is saved in composer state and enables Continue', (
    tester,
  ) async {
    final harness = await _pumpComposer(tester, type: PostType.text);

    await tester.enterText(
      find.byKey(const Key('composer-text-field')),
      '  Une publication source prête à adapter.  ',
    );
    await tester.pump();

    expect(
      harness.container.read(composerControllerProvider).caption,
      '  Une publication source prête à adapter.  ',
    );
    expect(_continueButton(tester).onPressed, isNotNull);
    expect(find.text('Votre contenu source est prêt.'), findsOneWidget);
  });

  testWidgets('whitespace-only text remains invalid', (tester) async {
    await _pumpComposer(tester, type: PostType.text);
    await tester.enterText(
      find.byKey(const Key('composer-text-field')),
      '   \n ',
    );
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('photo selection is compressed and previewed', (tester) async {
    final service = _FakeMediaService(
      imageResults: [XFile('C:/media/source-photo.jpg')],
      compressedPrefix: 'compressed-',
    );
    final harness = await _pumpComposer(
      tester,
      type: PostType.image,
      mediaService: service,
    );

    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();

    expect(find.text('compressed-source-photo.jpg'), findsOneWidget);
    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/compressed-source-photo.jpg',
    ]);
    expect(service.compressedPaths, ['C:/media/source-photo.jpg']);
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('photo can be replaced', (tester) async {
    final service = _FakeMediaService(
      imageResults: [
        XFile('C:/media/first.jpg'),
        XFile('C:/media/replacement.jpg'),
      ],
    );
    final harness = await _pumpComposer(
      tester,
      type: PostType.image,
      mediaService: service,
    );
    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();
    await _tapAfterScroll(tester, find.text('Remplacer'));

    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/replacement.jpg',
    ]);
  });

  testWidgets('photo can be removed', (tester) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.image,
      mediaPaths: const ['C:/media/photo.jpg'],
    );

    await _tapAfterScroll(tester, find.text('Supprimer'));

    expect(
      harness.container.read(composerControllerProvider).mediaPaths,
      isEmpty,
    );
    expect(find.text('Ajouter une photo'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('photo picker cancellation preserves state without error', (
    tester,
  ) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.image,
      mediaService: _FakeMediaService(imageResults: [null]),
    );
    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();

    expect(
      harness.container.read(composerControllerProvider).mediaPaths,
      isEmpty,
    );
    expect(find.textContaining('Impossible'), findsNothing);
  });

  testWidgets('photo picker exposes a friendly error', (tester) async {
    await _pumpComposer(
      tester,
      type: PostType.image,
      mediaService: _FakeMediaService(error: StateError('raw picker error')),
    );
    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Impossible d’ajouter ce média'),
      findsOneWidget,
    );
    expect(find.textContaining('raw picker error'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('Erreur média.*Impossible')),
      findsOneWidget,
    );
  });

  testWidgets('media picking displays a processing state', (tester) async {
    final pendingImage = Completer<XFile?>();
    await _pumpComposer(
      tester,
      type: PostType.image,
      mediaService: _FakeMediaService(pendingImage: pendingImage),
    );
    await tester.tap(find.text('Ajouter une photo'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);

    pendingImage.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('video selection shows a clear selected state', (tester) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.video,
      mediaService: _FakeMediaService(
        videoResults: [XFile('C:/media/demo-video.mp4')],
      ),
    );
    await tester.tap(find.text('Ajouter une vidéo'));
    await tester.pumpAndSettle();

    expect(find.text('Vidéo prête'), findsOneWidget);
    expect(find.text('demo-video.mp4'), findsWidgets);
    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/demo-video.mp4',
    ]);
  });

  testWidgets('video can be replaced and removed', (tester) async {
    final service = _FakeMediaService(
      videoResults: [XFile('C:/media/first.mp4'), XFile('C:/media/second.mp4')],
    );
    final harness = await _pumpComposer(
      tester,
      type: PostType.video,
      mediaService: service,
    );
    await tester.tap(find.text('Ajouter une vidéo'));
    await tester.pumpAndSettle();
    await _tapAfterScroll(tester, find.text('Remplacer'));
    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/second.mp4',
    ]);

    await _tapAfterScroll(tester, find.text('Supprimer'));
    expect(
      harness.container.read(composerControllerProvider).mediaPaths,
      isEmpty,
    );
  });

  testWidgets('video picker handles cancellation and error', (tester) async {
    final service = _FakeMediaService(videoResults: [null]);
    final harness = await _pumpComposer(
      tester,
      type: PostType.video,
      mediaService: service,
    );
    await tester.tap(find.text('Ajouter une vidéo'));
    await tester.pumpAndSettle();
    expect(
      harness.container.read(composerControllerProvider).mediaPaths,
      isEmpty,
    );
    expect(find.textContaining('Impossible'), findsNothing);

    service.error = Exception('private failure');
    await tester.tap(find.text('Ajouter une vidéo'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Impossible d’ajouter ce média'),
      findsOneWidget,
    );
    expect(find.textContaining('private failure'), findsNothing);
  });

  testWidgets('carousel adds multiple media in picker order', (tester) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.carousel,
      mediaService: _FakeMediaService(
        carouselResults: [
          XFile('C:/media/one.jpg'),
          XFile('C:/media/two.jpg'),
          XFile('C:/media/three.jpg'),
        ],
      ),
    );
    await tester.tap(find.text('Ajouter des médias'));
    await tester.pumpAndSettle();

    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/one.jpg',
      'C:/media/two.jpg',
      'C:/media/three.jpg',
    ]);
    expect(find.text('Média 1'), findsOneWidget);
    expect(find.text('Média 2'), findsOneWidget);
    expect(find.text('Média 3'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('carousel order can be changed accessibly', (tester) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.carousel,
      mediaPaths: const ['C:/media/one.jpg', 'C:/media/two.jpg'],
    );
    final moveUp = find.byTooltip('Déplacer le média 2 vers le haut');
    await _tapAfterScroll(tester, moveUp);

    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/two.jpg',
      'C:/media/one.jpg',
    ]);
  });

  testWidgets('carousel media can be removed and validation updates', (
    tester,
  ) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.carousel,
      mediaPaths: const ['C:/media/one.jpg', 'C:/media/two.jpg'],
    );
    expect(_continueButton(tester).onPressed, isNotNull);

    await _tapAfterScroll(tester, find.byTooltip('Supprimer le média 2'));

    expect(harness.container.read(composerControllerProvider).mediaPaths, [
      'C:/media/one.jpg',
    ]);
    expect(_continueButton(tester).onPressed, isNull);
    expect(find.textContaining('au moins deux médias'), findsOneWidget);
  });

  testWidgets('AI placeholders are visible and inactive by default', (
    tester,
  ) async {
    final harness = await _pumpComposer(
      tester,
      type: PostType.text,
      caption: 'Texte original',
    );

    for (final label in [
      'Améliorer le texte',
      'Générer une légende',
      'Hashtags',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      harness.container.read(composerControllerProvider).caption,
      'Texte original',
    );
  });

  testWidgets('AI placeholder callbacks can be injected', (tester) async {
    var calls = 0;
    await _pumpComposer(
      tester,
      type: PostType.text,
      screen: ComposerScreen(onImproveText: () => calls++),
    );
    await _tapAfterScroll(tester, find.text('Améliorer le texte'));

    expect(calls, 1);
  });

  testWidgets('Continue transmits the complete source state', (tester) async {
    SocialPost? transmitted;
    final harness = await _pumpComposer(
      tester,
      type: PostType.image,
      caption: 'Légende source',
      mediaPaths: const ['C:/media/photo.jpg'],
      screen: ComposerScreen(onContinue: (post) => transmitted = post),
    );
    _continueButton(tester).onPressed!();
    await tester.pump();

    expect(transmitted?.type, PostType.image);
    expect(transmitted?.caption, 'Légende source');
    expect(transmitted?.mediaPaths, ['C:/media/photo.jpg']);
    expect(
      harness.container.read(composerControllerProvider).caption,
      'Légende source',
    );
  });

  testWidgets('Continue opens the existing networks preparatory route', (
    tester,
  ) async {
    await _pumpComposer(
      tester,
      type: PostType.text,
      caption: 'Publication valide',
    );
    _continueButton(tester).onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Étape réseaux préparatoire'), findsOneWidget);
  });

  testWidgets('back returns to Post Type without clearing draft state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(composerControllerProvider.notifier)
      ..setType(PostType.text)
      ..setCaption('Brouillon conservé');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _NavigationHarness(),
      ),
    );
    await tester.tap(find.text('Ouvrir le Composer'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Écran Post Type'), findsOneWidget);
    expect(
      container.read(composerControllerProvider).caption,
      'Brouillon conservé',
    );
  });

  for (final size in [const Size(320, 700), const Size(390, 844)]) {
    testWidgets('supports ${size.width.toInt()} px without overflow', (
      tester,
    ) async {
      await _setViewport(tester, size);
      await _pumpComposer(
        tester,
        type: PostType.carousel,
        mediaPaths: const [
          'C:/media/a-very-long-media-file-name-one.jpg',
          'C:/media/a-very-long-media-file-name-two.jpg',
        ],
        configureViewport: false,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports enlarged text and long content', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpComposer(
      tester,
      type: PostType.text,
      caption: List.filled(60, 'contenu').join(' '),
      textScaler: const TextScaler.linear(1.3),
      configureViewport: false,
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('remains usable with the keyboard inset', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await _pumpComposer(tester, type: PostType.text, configureViewport: false);
    await tester.tap(find.byKey(const Key('composer-text-field')));
    await tester.enterText(
      find.byKey(const Key('composer-text-field')),
      'Texte avec clavier ouvert',
    );
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Continuer'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('supports ${mode.name} theme', (tester) async {
      await _pumpComposer(tester, type: PostType.image, themeMode: mode);
      final context = tester.element(find.byType(ComposerScreen));
      expect(
        Theme.of(context).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('exposes editor, media and CTA semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpComposer(tester, type: PostType.image);

    expect(
      find.bySemanticsLabel(RegExp('Aucune photo sélectionnée')),
      findsWidgets,
    );
    expect(find.bySemanticsLabel('Ajouter une photo'), findsWidgets);
    expect(find.bySemanticsLabel('Continuer'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('Post Type still targets the Composer route contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          routes: {AppRoutes.postMedia: (_) => const ComposerScreen()},
          home: const PostTypeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Texte'));
    await tester.pump();
    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('post-type-continue')),
        matching: find.byType(FilledButton),
      ),
    );
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byType(ComposerScreen), findsOneWidget);
  });

  testWidgets('Create Hub and exact five-tab AppShell remain unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShell.testing(
          initialRoute: AppRoutes.create,
          pages: const [
            _Placeholder('Accueil'),
            CreateHubScreen(),
            _Placeholder('Calendrier'),
            _Placeholder('Statistiques'),
            _Placeholder('Profil'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(AppShell.destinations, hasLength(5));
    expect(find.text('Nouvelle publication'), findsOneWidget);
  });
}

FilledButton _continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('composer-continue')),
        matching: find.byType(FilledButton),
      ),
    );

Future<void> _tapAfterScroll(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<_Harness> _pumpComposer(
  WidgetTester tester, {
  required PostType type,
  MediaService? mediaService,
  String caption = '',
  List<String> mediaPaths = const [],
  Widget screen = const ComposerScreen(),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool configureViewport = true,
}) async {
  if (configureViewport) await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer(
    overrides: [
      if (mediaService != null)
        mediaServiceProvider.overrideWithValue(mediaService),
    ],
  );
  addTearDown(container.dispose);
  container.read(composerControllerProvider.notifier)
    ..setType(type)
    ..setCaption(caption)
    ..setMedia(mediaPaths);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _TestApp(
        screen: screen,
        themeMode: themeMode,
        textScaler: textScaler,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(container);
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _Harness {
  const _Harness(this.container);

  final ProviderContainer container;
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.screen,
    required this.themeMode,
    required this.textScaler,
  });

  final Widget screen;
  final ThemeMode themeMode;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
      routes: {
        AppRoutes.postPlatforms:
            (_) => const _Placeholder('Étape réseaux préparatoire'),
      },
      home: screen,
    );
  }
}

class _NavigationHarness extends StatelessWidget {
  const _NavigationHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      routes: {AppRoutes.postMedia: (_) => const ComposerScreen()},
      home: Builder(
        builder:
            (context) => Scaffold(
              body: Column(
                children: [
                  const Text('Écran Post Type'),
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(context, AppRoutes.postMedia),
                    child: const Text('Ouvrir le Composer'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

class _FakeMediaService extends MediaService {
  _FakeMediaService({
    this.imageResults = const [],
    this.videoResults = const [],
    this.carouselResults = const [],
    this.error,
    this.compressedPrefix,
    this.pendingImage,
  });

  final List<XFile?> imageResults;
  final List<XFile?> videoResults;
  final List<XFile> carouselResults;
  final String? compressedPrefix;
  final Completer<XFile?>? pendingImage;
  Object? error;
  final compressedPaths = <String>[];
  var _imageIndex = 0;
  var _videoIndex = 0;

  @override
  Future<XFile?> pickImage() async {
    if (error != null) throw error!;
    if (pendingImage != null) return pendingImage!.future;
    return imageResults[_imageIndex++];
  }

  @override
  Future<XFile?> pickVideo() async {
    if (error != null) throw error!;
    return videoResults[_videoIndex++];
  }

  @override
  Future<List<XFile>> pickImages() async {
    if (error != null) throw error!;
    return carouselResults;
  }

  @override
  Future<XFile?> compressImage(XFile source, {int quality = 82}) async {
    compressedPaths.add(source.path);
    final prefix = compressedPrefix;
    if (prefix == null) return null;
    final fileName = source.path.split(RegExp(r'[/\\]')).last;
    return XFile('C:/media/$prefix$fileName');
  }
}
