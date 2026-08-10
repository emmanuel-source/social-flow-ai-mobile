import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/platforms_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  const connected = <SocialPlatform>{
    SocialPlatform.instagram,
    SocialPlatform.facebook,
    SocialPlatform.tiktok,
    SocialPlatform.youtube,
    SocialPlatform.linkedin,
  };
  const disconnected = <SocialPlatform>{
    SocialPlatform.x,
    SocialPlatform.threads,
    SocialPlatform.pinterest,
    SocialPlatform.snapchat,
  };

  testWidgets('présente clairement l’étape de sélection', (tester) async {
    await _pumpPlatforms(tester);

    expect(find.text('Choisissez vos réseaux'), findsOneWidget);
    expect(find.text('Étape 3 · Diffusion'), findsOneWidget);
    expect(find.text('Où souhaitez-vous publier ?'), findsOneWidget);
    expect(find.text('Données de démonstration'), findsOneWidget);
    expect(find.textContaining('Compatibilité préliminaire'), findsOneWidget);
  });

  for (final platform in SocialPlatform.values) {
    testWidgets('affiche ${platform.label}', (tester) async {
      await _pumpPlatforms(tester);
      await _reveal(tester, find.byKey(Key('platform-${platform.name}')));

      expect(find.text(platform.label), findsWidgets);
    });
  }

  for (final platform in connected) {
    testWidgets('${platform.label} est un compte connecté sélectionnable', (
      tester,
    ) async {
      final harness = await _pumpPlatforms(tester);
      final card = find.byKey(Key('platform-${platform.name}'));
      await _tapVisible(tester, card);

      expect(
        harness.container.read(composerControllerProvider).platforms,
        contains(platform),
      );
      expect(find.text('Connecté'), findsWidgets);
    });
  }

  for (final platform in disconnected) {
    testWidgets('${platform.label} reste non connecté et non sélectionnable', (
      tester,
    ) async {
      SocialPlatform? requested;
      final harness = await _pumpPlatforms(
        tester,
        screen: PlatformsScreen(onConnect: (value) => requested = value),
      );
      await _tapVisible(tester, find.byKey(Key('platform-${platform.name}')));

      expect(requested, platform);
      expect(
        harness.container.read(composerControllerProvider).platforms,
        isNot(contains(platform)),
      );
      expect(find.text('Non connecté'), findsWidgets);
    });
  }

  testWidgets('démarre sans sélection et désactive Continuer', (tester) async {
    await _pumpPlatforms(tester);

    expect(find.text('0 réseau sélectionné'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('sélectionne et désélectionne un compte', (tester) async {
    final harness = await _pumpPlatforms(tester);
    final instagram = find.byKey(const Key('platform-instagram'));

    await _tapVisible(tester, instagram);
    expect(find.text('1 réseau sélectionné'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNotNull);

    await _tapVisible(tester, instagram);
    expect(
      harness.container.read(composerControllerProvider).platforms,
      isEmpty,
    );
    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('autorise une sélection multiple', (tester) async {
    final harness = await _pumpPlatforms(tester);
    await _tapVisible(tester, find.byKey(const Key('platform-instagram')));
    await _tapVisible(tester, find.byKey(const Key('platform-linkedin')));

    expect(find.text('2 réseaux sélectionnés'), findsOneWidget);
    expect(harness.container.read(composerControllerProvider).platforms, {
      SocialPlatform.instagram,
      SocialPlatform.linkedin,
    });
  });

  testWidgets(
    'Tout sélectionner cible seulement les cinq comptes disponibles',
    (tester) async {
      final harness = await _pumpPlatforms(tester);
      await tester.tap(find.text('Tout sélectionner'));
      await tester.pump();

      expect(
        harness.container.read(composerControllerProvider).platforms,
        connected,
      );
      expect(find.text('5 réseaux sélectionnés'), findsOneWidget);
      expect(find.text('Tout désélectionner'), findsOneWidget);
    },
  );

  testWidgets('Tout désélectionner efface la sélection', (tester) async {
    final harness = await _pumpPlatforms(tester, platforms: connected);
    await tester.tap(find.text('Tout désélectionner'));
    await tester.pump();

    expect(
      harness.container.read(composerControllerProvider).platforms,
      isEmpty,
    );
  });

  testWidgets('préserve type, texte et médias du Composer', (tester) async {
    final harness = await _pumpPlatforms(
      tester,
      type: PostType.carousel,
      caption: 'Une légende source',
      mediaPaths: const ['one.jpg', 'two.jpg'],
    );
    await _tapVisible(tester, find.byKey(const Key('platform-facebook')));

    final post = harness.container.read(composerControllerProvider);
    expect(post.type, PostType.carousel);
    expect(post.caption, 'Une légende source');
    expect(post.mediaPaths, ['one.jpg', 'two.jpg']);
  });

  testWidgets('Continuer transmet le brouillon complet', (tester) async {
    SocialPost? transmitted;
    final harness = await _pumpPlatforms(
      tester,
      caption: 'Texte source',
      platforms: const {SocialPlatform.instagram},
      screen: PlatformsScreen(onContinue: (post) => transmitted = post),
    );
    await _reveal(tester, find.byKey(const Key('platforms-continue')));
    _continueButton(tester).onPressed!();
    await tester.pump();

    expect(transmitted?.caption, 'Texte source');
    expect(transmitted?.platforms, {SocialPlatform.instagram});
    expect(
      harness.container.read(composerControllerProvider).platforms,
      transmitted?.platforms,
    );
  });

  testWidgets('Continuer ouvre la route centrale d’adaptation réservée', (
    tester,
  ) async {
    await _pumpPlatforms(tester, platforms: const {SocialPlatform.instagram});
    await _reveal(tester, find.byKey(const Key('platforms-continue')));
    _continueButton(tester).onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Adaptation future'), findsOneWidget);
  });

  testWidgets('un compte déconnecté ouvre la gestion des comptes', (
    tester,
  ) async {
    await _pumpPlatforms(tester);
    await _tapVisible(tester, find.byKey(const Key('platform-x')));

    expect(find.text('Gestion des comptes'), findsOneWidget);
  });

  testWidgets(
    'la sélection est conservée après un retour de l’étape suivante',
    (tester) async {
      final harness = await _pumpPlatforms(
        tester,
        platforms: const {SocialPlatform.youtube},
      );
      await _reveal(tester, find.byKey(const Key('platforms-continue')));
      _continueButton(tester).onPressed!();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(harness.container.read(composerControllerProvider).platforms, {
        SocialPlatform.youtube,
      });
      expect(find.text('1 réseau sélectionné'), findsOneWidget);
    },
  );

  for (final size in [const Size(320, 700), const Size(390, 844)]) {
    testWidgets('reste sans overflow à ${size.width.toInt()} px', (
      tester,
    ) async {
      await _setViewport(tester, size);
      await _pumpPlatforms(
        tester,
        configureViewport: false,
        platforms: connected,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1400),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supporte les textes agrandis sur petit écran', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPlatforms(
      tester,
      configureViewport: false,
      textScaler: const TextScaler.linear(1.3),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1400),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('fonctionne avec le thème ${mode.name}', (tester) async {
      await _pumpPlatforms(tester, themeMode: mode);
      final context = tester.element(find.byType(PlatformsScreen));

      expect(
        Theme.of(context).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'expose état, compte et sélection aux technologies d’assistance',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpPlatforms(tester, platforms: const {SocialPlatform.instagram});

      expect(
        find.bySemanticsLabel(
          RegExp('Instagram.*@socialflow.*connecté.*compatible.*sélectionné'),
        ),
        findsOneWidget,
      );
      await _reveal(tester, find.byKey(const Key('platform-snapchat')));
      expect(
        find.bySemanticsLabel(
          RegExp('Snapchat.*non connecté.*non sélectionné'),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );
}

Future<_Harness> _pumpPlatforms(
  WidgetTester tester, {
  PostType type = PostType.text,
  String caption = '',
  List<String> mediaPaths = const [],
  Set<SocialPlatform> platforms = const {},
  Widget screen = const PlatformsScreen(),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool configureViewport = true,
}) async {
  if (configureViewport) await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(composerControllerProvider.notifier)
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
          AppRoutes.postAdapt:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Adaptation future')),
                body: const SizedBox.shrink(),
              ),
          AppRoutes.accounts:
              (_) => const Scaffold(body: Text('Gestion des comptes')),
        },
        home: screen,
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
        of: find.byKey(const Key('platforms-continue')),
        matching: find.byType(FilledButton),
      ),
    );

class _Harness {
  const _Harness(this.container);

  final ProviderContainer container;
}
