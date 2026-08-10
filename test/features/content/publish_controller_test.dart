import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/publish_intent.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/domain/services/publish_intent_submitter.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/publish_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/post_publish_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('1 mode initial', () {
    final harness = _controllerHarness();
    expect(harness.state.mode, PublishMode.now);
    expect(harness.state.status, PublishSubmissionStatus.editing);
  });

  test('2 sélection Now', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectMode(PublishMode.now);
    expect(harness.state.mode, PublishMode.now);
  });

  test('3 sélection Scheduled', () {
    final harness = _controllerHarness();
    harness.controller.selectMode(PublishMode.scheduled);
    expect(harness.state.mode, PublishMode.scheduled);
  });

  test('4 date future valide', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectDate(DateTime(2026, 8, 11))
      ..selectTime(hour: 9, minute: 30);
    expect(harness.state.isValidAt(_now), isTrue);
  });

  test('5 date passée invalide', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectDate(DateTime(2026, 8, 9))
      ..selectTime(hour: 18, minute: 0);
    expect(harness.state.isValidAt(_now), isFalse);
    expect(
      harness.state.validationMessage(_now),
      'Choisissez une date et une heure futures.',
    );
  });

  test('6 aujourd’hui et heure future', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectDate(_now)
      ..selectTime(hour: 16, minute: 0);
    expect(harness.state.isValidAt(_now), isTrue);
  });

  test('7 aujourd’hui et heure passée', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectDate(_now)
      ..selectTime(hour: 13, minute: 59);
    expect(harness.state.isValidAt(_now), isFalse);
  });

  test('8 timezone conservé', () {
    final harness = _controllerHarness(timeZone: 'Africa/Lubumbashi');
    expect(harness.state.timeZone, 'Africa/Lubumbashi');
    harness.controller.setTimeZone('Europe/Paris');
    expect(harness.state.timeZone, 'Europe/Paris');
  });

  test('9 création PublishIntent Now', () {
    final harness = _controllerHarness();
    final intent = harness.controller.createIntent(_post);
    expect(intent?.mode, PublishMode.now);
    expect(intent?.scheduledAt, isNull);
    expect(intent?.selectedPlatforms, _post.platforms);
  });

  test('10 création PublishIntent Scheduled', () {
    final harness = _controllerHarness();
    harness.controller
      ..selectMode(PublishMode.scheduled)
      ..selectDate(DateTime(2026, 8, 15))
      ..selectTime(hour: 18, minute: 30);
    final intent = harness.controller.createIntent(_post);
    expect(intent?.mode, PublishMode.scheduled);
    expect(intent?.scheduledAt, DateTime(2026, 8, 15, 18, 30));
    expect(intent?.timeZone, 'Europe/Paris');
  });

  test('11 post source intact', () async {
    final harness = _controllerHarness();
    await harness.controller.submit(_post);
    expect(identical(harness.state.intent?.post, _post), isTrue);
    expect(_post.caption, 'Contenu source');
  });

  test('12 variantes intactes', () async {
    final harness = _controllerHarness();
    final variants = _post.platformVariants;
    await harness.controller.submit(_post);
    expect(
      identical(harness.state.intent?.post.platformVariants, variants),
      isTrue,
    );
  });

  test('13 submitting', () async {
    final completer = Completer<void>();
    final submitter = _RecordingSubmitter(completer: completer);
    final harness = _controllerHarness(submitter: submitter);
    final pending = harness.controller.submit(_post);
    expect(harness.state.status, PublishSubmissionStatus.submitting);
    completer.complete();
    await pending;
  });

  test('14 succès', () async {
    final harness = _controllerHarness();
    expect(await harness.controller.submit(_post), isTrue);
    expect(harness.state.status, PublishSubmissionStatus.success);
  });

  test('15 erreur', () async {
    final harness = _controllerHarness(
      submitter: _RecordingSubmitter(failures: 1),
    );
    expect(await harness.controller.submit(_post), isFalse);
    expect(harness.state.status, PublishSubmissionStatus.error);
    expect(harness.state.errorMessage, contains('Réessayez'));
  });

  test('16 retry', () async {
    final submitter = _RecordingSubmitter(failures: 1);
    final harness = _controllerHarness(submitter: submitter);
    expect(await harness.controller.submit(_post), isFalse);
    expect(await harness.controller.submit(_post), isTrue);
    expect(submitter.calls, 2);
  });

  test('17 double-submit bloqué', () async {
    final completer = Completer<void>();
    final submitter = _RecordingSubmitter(completer: completer);
    final harness = _controllerHarness(submitter: submitter);
    final first = harness.controller.submit(_post);
    expect(await harness.controller.submit(_post), isFalse);
    expect(submitter.calls, 1);
    completer.complete();
    await first;
  });

  testWidgets('18 composer reset après succès', (tester) async {
    final harness = await _pumpWorkflow(tester);
    await _tapSubmit(tester);
    expect(harness.container.read(composerControllerProvider).caption, isEmpty);
    expect(find.text('Publication prête'), findsOneWidget);
  });

  testWidgets('19 composer conservé après erreur', (tester) async {
    final harness = await _pumpWorkflow(
      tester,
      submitter: _RecordingSubmitter(failures: 1),
    );
    await _tapSubmit(tester);
    expect(
      harness.container.read(composerControllerProvider).caption,
      'Contenu source',
    );
    expect(find.byKey(const Key('publish-error')), findsOneWidget);
  });
}

final _now = DateTime(2026, 8, 10, 14, 30);

final _post = SocialPost(
  type: PostType.text,
  caption: 'Contenu source',
  platforms: const {SocialPlatform.instagram, SocialPlatform.linkedin},
  mediaPaths: const [],
  mode: PublicationMode.draft,
  platformVariants: {
    SocialPlatform.instagram: PlatformPostVariant.fromSource(
      platform: SocialPlatform.instagram,
      sourceCaption: 'Contenu source',
    ),
    SocialPlatform.linkedin: PlatformPostVariant.fromSource(
      platform: SocialPlatform.linkedin,
      sourceCaption: 'Contenu source',
    ),
  },
);

_ControllerHarness _controllerHarness({
  String timeZone = 'Europe/Paris',
  PublishIntentSubmitter? submitter,
}) {
  final container = ProviderContainer(
    overrides: [
      publishClockProvider.overrideWithValue(() => _now),
      publishTimeZoneProvider.overrideWithValue(timeZone),
      publishIntentSubmitterProvider.overrideWithValue(
        submitter ?? _RecordingSubmitter(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return _ControllerHarness(container);
}

Future<_WidgetHarness> _pumpWorkflow(
  WidgetTester tester, {
  PublishIntentSubmitter? submitter,
}) async {
  final container = ProviderContainer(
    overrides: [
      publishClockProvider.overrideWithValue(() => _now),
      publishTimeZoneProvider.overrideWithValue('Europe/Paris'),
      publishIntentSubmitterProvider.overrideWithValue(
        submitter ?? _RecordingSubmitter(),
      ),
    ],
  );
  addTearDown(container.dispose);
  final composer = container.read(composerControllerProvider.notifier);
  composer
    ..setType(PostType.text)
    ..setCaption('Contenu source')
    ..setPlatforms(const {SocialPlatform.instagram, SocialPlatform.linkedin});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const PostPublishScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _WidgetHarness(container);
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final finder = find.byKey(const Key('publish-submit'));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _ControllerHarness {
  const _ControllerHarness(this.container);

  final ProviderContainer container;

  PublishController get controller =>
      container.read(publishControllerProvider.notifier);
  PublishState get state => container.read(publishControllerProvider);
}

class _WidgetHarness {
  const _WidgetHarness(this.container);

  final ProviderContainer container;
}

class _RecordingSubmitter implements PublishIntentSubmitter {
  _RecordingSubmitter({this.failures = 0, this.completer});

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
