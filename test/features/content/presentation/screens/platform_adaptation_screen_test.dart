import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/platform_adaptation_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  testWidgets('20 rendu initial', (tester) async {
    await _pumpAdaptation(tester);
    expect(find.byType(PlatformAdaptationScreen), findsOneWidget);
    expect(find.byKey(const Key('adaptation-caption-field')), findsOneWidget);
  });

  testWidgets('21 affiche le titre et le sous-titre', (tester) async {
    await _pumpAdaptation(tester);
    expect(find.text('Adapter votre contenu'), findsOneWidget);
    expect(find.text('Étape 4 · Versions par réseau'), findsOneWidget);
  });

  testWidgets('22 affiche le contenu source sans second éditeur', (
    tester,
  ) async {
    await _pumpAdaptation(tester, caption: 'Source de référence');
    expect(find.text('Contenu source'), findsOneWidget);
    expect(find.text('Source de référence'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('23 affiche uniquement les plateformes sélectionnées', (
    tester,
  ) async {
    await _pumpAdaptation(
      tester,
      platforms: const {SocialPlatform.instagram, SocialPlatform.linkedin},
    );
    expect(find.byKey(const Key('adaptation-instagram')), findsOneWidget);
    expect(find.byKey(const Key('adaptation-linkedin')), findsOneWidget);
    expect(find.byKey(const Key('adaptation-tiktok')), findsNothing);
  });

  testWidgets('24 annonce Instagram comme plateforme active initiale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpAdaptation(tester);
    expect(
      find.bySemanticsLabel('Instagram, plateforme active'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('25 change de plateforme active', (tester) async {
    await _pumpAdaptation(tester);
    await tester.tap(find.byKey(const Key('adaptation-linkedin')));
    await tester.pump();
    expect(find.text('Version LinkedIn'), findsOneWidget);
  });

  testWidgets('26 charge la caption de la plateforme active', (tester) async {
    final harness = await _pumpAdaptation(tester);
    harness.controller.updatePlatformVariant(
      SocialPlatform.linkedin,
      'Version LinkedIn',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('adaptation-linkedin')));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Version LinkedIn',
    );
  });

  testWidgets('27 persiste une modification manuelle', (tester) async {
    final harness = await _pumpAdaptation(tester);
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Version Instagram',
    );
    await tester.pump();
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'Version Instagram',
    );
    expect(harness.post.caption, 'Source A');
  });

  testWidgets('28 conserve les captions entre les changements de plateforme', (
    tester,
  ) async {
    await _pumpAdaptation(tester);
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Instagram B',
    );
    await tester.tap(find.byKey(const Key('adaptation-linkedin')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'LinkedIn C',
    );
    await tester.tap(find.byKey(const Key('adaptation-instagram')));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Instagram B',
    );
  });

  testWidgets('29 affiche Original lorsque la variante suit la source', (
    tester,
  ) async {
    await _pumpAdaptation(tester);
    expect(find.text('Original'), findsOneWidget);
  });

  testWidgets('30 affiche Personnalisé après édition', (tester) async {
    await _pumpAdaptation(tester);
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Version distincte',
    );
    await tester.pump();
    expect(find.text('Personnalisé'), findsOneWidget);
  });

  testWidgets('31 reset restaure uniquement la plateforme active', (
    tester,
  ) async {
    final harness = await _pumpAdaptation(tester);
    harness.controller.updatePlatformVariant(SocialPlatform.linkedin, 'C');
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'B',
    );
    await _tapVisible(tester, find.text('Réinitialiser depuis la source'));
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'Source A',
    );
    expect(
      harness.post.platformVariants[SocialPlatform.linkedin]?.caption,
      'C',
    );
  });

  testWidgets('32 présente l’action IA future désactivée', (tester) async {
    await _pumpAdaptation(tester);
    await _reveal(tester, find.textContaining('Adapter avec Social Flow AI'));
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
    expect(find.textContaining('Bientôt'), findsOneWidget);
  });

  testWidgets('33 callback IA contrôlé ne modifie aucun texte', (tester) async {
    SocialPlatform? requested;
    final harness = await _pumpAdaptation(
      tester,
      screen: PlatformAdaptationScreen(
        onAiAdapt: (platform) => requested = platform,
      ),
    );
    await _tapVisible(tester, find.text('Adapter avec Social Flow AI'));
    expect(requested, SocialPlatform.instagram);
    expect(harness.post.caption, 'Source A');
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'Source A',
    );
  });

  for (final entry in <(int, PostType, List<String>, String)>[
    (34, PostType.text, const [], 'Publication texte'),
    (35, PostType.image, const ['photo.jpg'], '1 photo source'),
    (36, PostType.video, const ['video.mp4'], '1 vidéo source'),
    (37, PostType.carousel, const ['one.jpg', 'two.jpg'], '2 médias source'),
  ]) {
    testWidgets('${entry.$1} gère ${entry.$2.name}', (tester) async {
      await _pumpAdaptation(tester, type: entry.$2, mediaPaths: entry.$3);
      expect(find.text(entry.$4), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNotNull);
    });
  }

  testWidgets('38 Retour revient à Platforms', (tester) async {
    await _pumpNavigationHarness(tester);
    await tester.tap(find.text('Ouvrir Adaptation'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Écran Platforms'), findsOneWidget);
  });

  testWidgets('39 conserve les variantes après Retour', (tester) async {
    final harness = await _pumpNavigationHarness(tester);
    await tester.tap(find.text('Ouvrir Adaptation'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Version conservée',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      harness.post.platformVariants[SocialPlatform.instagram]?.caption,
      'Version conservée',
    );
  });

  testWidgets('40 Continuer reflète la validation générique des variantes', (
    tester,
  ) async {
    await _pumpAdaptation(tester);
    await _reveal(tester, find.byKey(const Key('adaptation-continue')));
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      '   ',
    );
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Version valide',
    );
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('41 Continuer ouvre la route Preview centrale', (tester) async {
    await _pumpAdaptation(tester);
    await _reveal(tester, find.byKey(const Key('adaptation-continue')));
    _continueButton(tester).onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Preview SFA-PUB-005'), findsOneWidget);
  });

  testWidgets('42 transmet toutes les variantes au futur Preview', (
    tester,
  ) async {
    SocialPost? transmitted;
    await _pumpAdaptation(
      tester,
      screen: PlatformAdaptationScreen(
        onContinue: (post) => transmitted = post,
      ),
    );
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Instagram B',
    );
    await _reveal(tester, find.byKey(const Key('adaptation-continue')));
    _continueButton(tester).onPressed!();
    expect(transmitted?.activePlatformVariants, hasLength(2));
    expect(
      transmitted?.platformVariants[SocialPlatform.instagram]?.caption,
      'Instagram B',
    );
  });

  for (final entry in <(int, Size)>[
    (43, const Size(320, 700)),
    (44, const Size(390, 844)),
  ]) {
    testWidgets('${entry.$1} supporte ${entry.$2.width.toInt()} px', (
      tester,
    ) async {
      await _setViewport(tester, entry.$2);
      await _pumpAdaptation(tester, configureViewport: false);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('45 supporte cinq plateformes sélectionnées', (tester) async {
    await _pumpAdaptation(tester, platforms: _fivePlatforms);
    for (final platform in _fivePlatforms) {
      expect(find.byKey(Key('adaptation-${platform.name}')), findsOneWidget);
    }
  });

  testWidgets('46 supporte le texte agrandi à 130 %', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpAdaptation(
      tester,
      configureViewport: false,
      textScaler: const TextScaler.linear(1.3),
      platforms: _fivePlatforms,
    );
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('47 reste utilisable avec le clavier ouvert', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await _pumpAdaptation(tester, configureViewport: false);
    await _reveal(tester, find.byKey(const Key('adaptation-caption-field')));
    await tester.tap(find.byKey(const Key('adaptation-caption-field')));
    await tester.enterText(
      find.byKey(const Key('adaptation-caption-field')),
      'Texte avec clavier',
    );
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Continuer vers l’aperçu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <(int, ThemeMode)>[
    (48, ThemeMode.light),
    (49, ThemeMode.dark),
  ]) {
    testWidgets('${entry.$1} supporte le thème ${entry.$2.name}', (
      tester,
    ) async {
      await _pumpAdaptation(tester, themeMode: entry.$2);
      final context = tester.element(find.byType(PlatformAdaptationScreen));
      expect(
        Theme.of(context).brightness,
        entry.$2 == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    });
  }

  testWidgets('50 expose les sémantiques essentielles', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpAdaptation(tester);
    expect(find.bySemanticsLabel(RegExp('Contenu source')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Version Instagram.*Original')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Continuer vers l’aperçu'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('51 caption longue et scroll complet restent sans overflow', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpAdaptation(
      tester,
      configureViewport: false,
      caption: List.filled(120, 'contenu').join(' '),
      platforms: _fivePlatforms,
    );
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

const _defaultPlatforms = {SocialPlatform.instagram, SocialPlatform.linkedin};
const _fivePlatforms = {
  SocialPlatform.instagram,
  SocialPlatform.facebook,
  SocialPlatform.tiktok,
  SocialPlatform.youtube,
  SocialPlatform.linkedin,
};

Future<_WidgetHarness> _pumpAdaptation(
  WidgetTester tester, {
  PostType type = PostType.text,
  String caption = 'Source A',
  List<String> mediaPaths = const [],
  Set<SocialPlatform> platforms = _defaultPlatforms,
  Widget screen = const PlatformAdaptationScreen(),
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
    ..setCaption(caption)
    ..setMedia(mediaPaths)
    ..setPlatforms(platforms);
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
          AppRoutes.postPreview:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Preview SFA-PUB-005')),
              ),
        },
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _WidgetHarness(container, controller);
}

Future<_WidgetHarness> _pumpNavigationHarness(WidgetTester tester) async {
  await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final controller = container.read(composerControllerProvider.notifier);
  controller
    ..setCaption('Source A')
    ..setPlatforms(_defaultPlatforms);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        routes: {
          AppRoutes.postAdapt: (_) => const PlatformAdaptationScreen(),
          AppRoutes.postPreview:
              (_) => const Scaffold(body: Text('Preview SFA-PUB-005')),
        },
        home: Builder(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Écran Platforms')),
                body: TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.postAdapt),
                  child: const Text('Ouvrir Adaptation'),
                ),
              ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _WidgetHarness(container, controller);
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

FilledButton _continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('adaptation-continue')),
        matching: find.byType(FilledButton),
      ),
    );

class _WidgetHarness {
  const _WidgetHarness(this.container, this.controller);

  final ProviderContainer container;
  final ComposerController controller;

  SocialPost get post => container.read(composerControllerProvider);
}
