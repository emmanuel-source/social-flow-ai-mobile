import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/publish_intent.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/domain/services/publish_intent_submitter.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/publish_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/post_publish_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  testWidgets('20 rendu écran', (tester) async {
    await _pumpPublish(tester);
    expect(find.byType(PostPublishScreen), findsOneWidget);
    expect(
      find.text('Choisissez quand diffuser votre contenu'),
      findsOneWidget,
    );
  });

  testWidgets('21 résumé post', (tester) async {
    await _pumpPublish(tester);
    expect(find.byKey(const Key('publish-summary')), findsOneWidget);
    expect(find.text('Texte'), findsOneWidget);
    expect(find.text('3 réseaux'), findsOneWidget);
  });

  testWidgets('22 plateformes', (tester) async {
    await _pumpPublish(tester);
    for (final label in ['Instagram', 'TikTok', 'LinkedIn']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('23 choix Publish now', (tester) async {
    final harness = await _pumpPublish(tester, mode: PublishMode.scheduled);
    await tester.tap(find.text('Publier maintenant'));
    await tester.pump();
    expect(harness.publish.mode, PublishMode.now);
  });

  testWidgets('24 choix Schedule', (tester) async {
    final harness = await _pumpPublish(tester);
    await tester.tap(find.text('Programmer'));
    await tester.pump();
    expect(harness.publish.mode, PublishMode.scheduled);
  });

  testWidgets('25 date visible uniquement en Scheduled et ouvre le picker', (
    tester,
  ) async {
    await _pumpPublish(tester);
    expect(find.byKey(const Key('publish-date')), findsNothing);
    await tester.tap(find.text('Programmer'));
    await tester.pumpAndSettle();
    final date = find.byKey(const Key('publish-date'));
    expect(date, findsOneWidget);
    await _tapVisible(tester, date);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('26 heure visible uniquement en Scheduled et ouvre le picker', (
    tester,
  ) async {
    await _pumpPublish(tester);
    expect(find.byKey(const Key('publish-time')), findsNothing);
    await tester.tap(find.text('Programmer'));
    await tester.pumpAndSettle();
    final time = find.byKey(const Key('publish-time'));
    expect(time, findsOneWidget);
    await _tapVisible(tester, time);
    expect(find.byType(TimePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(TimePickerDialog))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('27 timezone', (tester) async {
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      timeZone: 'Africa/Lubumbashi',
    );
    expect(find.text('Africa/Lubumbashi'), findsOneWidget);
  });

  testWidgets('28 CTA désactivé si schedule invalide', (tester) async {
    await _pumpPublish(tester, mode: PublishMode.scheduled);
    expect(_submitButton(tester).onPressed, isNull);
    expect(find.text('Sélectionnez une date et une heure.'), findsOneWidget);
  });

  testWidgets('29 CTA actif si valide', (tester) async {
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
    );
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('30 loading', (tester) async {
    final completer = Completer<void>();
    await _pumpPublish(tester, submitter: _TestSubmitter(completer: completer));
    final submit = find.byKey(const Key('publish-submit'));
    await _tapWithoutSettling(tester, submit);
    expect(find.byKey(const Key('publish-loading')), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('31 erreur', (tester) async {
    final harness = await _pumpPublish(
      tester,
      submitter: _TestSubmitter(failures: 1),
    );
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(find.byKey(const Key('publish-error')), findsOneWidget);
    expect(harness.post.caption, 'Contenu source de démonstration');
  });

  testWidgets('32 retry', (tester) async {
    final submitter = _TestSubmitter(failures: 1);
    await _pumpPublish(tester, submitter: submitter);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    await _tapVisible(tester, find.text('Réessayer'));
    expect(find.byKey(const Key('publish-success')), findsOneWidget);
    expect(submitter.calls, 2);
  });

  testWidgets('33 succès Now', (tester) async {
    await _pumpPublish(tester);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(find.text('Publication prête'), findsOneWidget);
    expect(find.text('3 réseaux'), findsOneWidget);
  });

  testWidgets('34 succès Scheduled', (tester) async {
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
      timeZone: 'Africa/Lubumbashi',
    );
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(find.text('Publication programmée'), findsWidgets);
    expect(find.text('15 août 2026 · 18:30'), findsOneWidget);
    expect(find.text('Africa/Lubumbashi'), findsOneWidget);
  });

  testWidgets('35 wording mode démo et non mensonger', (tester) async {
    await _pumpPublish(tester);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(find.text('Mode démonstration'), findsOneWidget);
    expect(find.textContaining('Aucun envoi réel'), findsOneWidget);
    expect(find.textContaining('Publié avec succès'), findsNothing);
  });

  testWidgets('36 View Calendar', (tester) async {
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
    );
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    await _tapVisible(tester, find.byKey(const Key('publish-view-calendar')));
    expect(find.text('Destination Calendrier'), findsOneWidget);
  });

  testWidgets('37 Home', (tester) async {
    await _pumpPublish(tester);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    await _tapVisible(tester, find.byKey(const Key('publish-home')));
    expect(find.text('Destination Accueil'), findsOneWidget);
  });

  testWidgets('38 Retour Preview', (tester) async {
    final harness = await _pumpNavigationHarness(tester);
    await tester.tap(find.text('Ouvrir Publish'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Écran Preview'), findsOneWidget);
    expect(harness.post.caption, 'Contenu source de démonstration');
  });

  testWidgets('39 state conservé avant succès', (tester) async {
    final harness = await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
    );
    final before = harness.post;
    harness.container
        .read(publishControllerProvider.notifier)
        .selectMode(PublishMode.now);
    await tester.pump();
    expect(harness.post.caption, before.caption);
    expect(harness.post.platformVariants, before.platformVariants);
  });

  testWidgets('40 state nettoyé après succès', (tester) async {
    final harness = await _pumpPublish(tester);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(harness.post.caption, isEmpty);
    expect(harness.post.platforms, isEmpty);
    expect(harness.post.platformVariants, isEmpty);
  });

  for (final entry in <(int, Size)>[
    (41, const Size(320, 700)),
    (42, const Size(390, 844)),
  ]) {
    testWidgets('${entry.$1} supporte ${entry.$2.width.toInt()} px', (
      tester,
    ) async {
      await _setViewport(tester, entry.$2);
      await _pumpPublish(tester, configureViewport: false);
      await _scrollToEnd(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('43 cinq plateformes', (tester) async {
    await _pumpPublish(tester, platforms: _fivePlatforms);
    for (final platform in _fivePlatforms) {
      expect(find.text(platform.label), findsOneWidget);
    }
  });

  testWidgets('44 texte agrandi', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPublish(
      tester,
      configureViewport: false,
      textScaler: const TextScaler.linear(1.3),
      platforms: _fivePlatforms,
      timeZone: 'America/Argentina/Buenos_Aires',
    );
    await _scrollToEnd(tester);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <(int, ThemeMode)>[
    (45, ThemeMode.light),
    (46, ThemeMode.dark),
  ]) {
    testWidgets('${entry.$1} thème ${entry.$2.name}', (tester) async {
      await _pumpPublish(tester, themeMode: entry.$2);
      final context = tester.element(find.byType(PostPublishScreen));
      expect(
        Theme.of(context).brightness,
        entry.$2 == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    });
  }

  testWidgets('47 sémantiques mode', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPublish(tester);
    expect(
      find.bySemanticsLabel(RegExp(r'Publier maintenant[\s\S]*Préparer')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Programmer[\s\S]*Choisir une date')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('48 sémantiques date', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
    );
    expect(
      find.bySemanticsLabel(RegExp('Date de programmation 15 août 2026')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('49 sémantiques time', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPublish(
      tester,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
    );
    expect(
      find.bySemanticsLabel(RegExp('Heure de programmation 18:30')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('50 sémantiques success et error', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPublish(tester, submitter: _TestSubmitter(failures: 1));
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(
      find.bySemanticsLabel(RegExp('La préparation a échoué')),
      findsOneWidget,
    );

    await _pumpPublish(tester);
    await _tapVisible(tester, find.byKey(const Key('publish-submit')));
    expect(find.bySemanticsLabel(RegExp('Publication prête')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('51 absence overflow', (tester) async {
    await _setViewport(tester, const Size(320, 700));
    await _pumpPublish(
      tester,
      configureViewport: false,
      mode: PublishMode.scheduled,
      scheduledAt: DateTime(2026, 8, 15, 18, 30),
      platforms: _fivePlatforms,
      timeZone: 'America/Argentina/Buenos_Aires',
      textScaler: const TextScaler.linear(1.3),
      caption: List.filled(70, 'contenu').join(' '),
    );
    await _scrollToEnd(tester);
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 8, 10, 14, 30);

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

Future<_PublishHarness> _pumpPublish(
  WidgetTester tester, {
  PublishMode mode = PublishMode.now,
  DateTime? scheduledAt,
  Set<SocialPlatform> platforms = _defaultPlatforms,
  String caption = 'Contenu source de démonstration',
  String timeZone = 'Europe/Paris',
  PublishIntentSubmitter? submitter,
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool configureViewport = true,
}) async {
  if (configureViewport) await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer(
    overrides: [
      publishClockProvider.overrideWithValue(() => _now),
      publishTimeZoneProvider.overrideWithValue(timeZone),
      publishIntentSubmitterProvider.overrideWithValue(
        submitter ?? _TestSubmitter(),
      ),
    ],
  );
  addTearDown(container.dispose);
  final composer = container.read(composerControllerProvider.notifier);
  composer
    ..setType(PostType.text)
    ..setCaption(caption)
    ..setPlatforms(platforms);
  final publish = container.read(publishControllerProvider.notifier);
  publish.selectMode(mode);
  if (scheduledAt != null) {
    publish
      ..selectDate(scheduledAt)
      ..selectTime(hour: scheduledAt.hour, minute: scheduledAt.minute);
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
          AppRoutes.home:
              (_) => const Scaffold(body: Text('Destination Accueil')),
          AppRoutes.calendar:
              (_) => const Scaffold(body: Text('Destination Calendrier')),
        },
        home: const PostPublishScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _PublishHarness(container);
}

Future<_PublishHarness> _pumpNavigationHarness(WidgetTester tester) async {
  await _setViewport(tester, const Size(390, 844));
  final container = ProviderContainer(
    overrides: [
      publishClockProvider.overrideWithValue(() => _now),
      publishTimeZoneProvider.overrideWithValue('Europe/Paris'),
      publishIntentSubmitterProvider.overrideWithValue(_TestSubmitter()),
    ],
  );
  addTearDown(container.dispose);
  container.read(composerControllerProvider.notifier)
    ..setType(PostType.text)
    ..setCaption('Contenu source de démonstration')
    ..setPlatforms(_defaultPlatforms);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        routes: {AppRoutes.postPublish: (_) => const PostPublishScreen()},
        home: Builder(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Écran Preview')),
                body: TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.postPublish),
                  child: const Text('Ouvrir Publish'),
                ),
              ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _PublishHarness(container);
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapWithoutSettling(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0, -1800),
  );
  await tester.pumpAndSettle();
}

FilledButton _submitButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.descendant(
    of: find.byKey(const Key('publish-submit')),
    matching: find.byType(FilledButton),
  ),
);

class _PublishHarness {
  const _PublishHarness(this.container);

  final ProviderContainer container;

  SocialPost get post => container.read(composerControllerProvider);
  PublishState get publish => container.read(publishControllerProvider);
}

class _TestSubmitter implements PublishIntentSubmitter {
  _TestSubmitter({this.failures = 0, this.completer});

  int failures;
  final Completer<void>? completer;
  int calls = 0;

  @override
  Future<void> submit(PublishIntent intent) async {
    calls++;
    if (completer != null) await completer!.future;
    if (failures > 0) {
      failures--;
      throw StateError('controlled failure');
    }
  }
}
