import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/drafts/domain/entities/draft.dart';
import 'package:socialflow_ai/features/drafts/domain/repositories/draft_repository.dart';
import 'package:socialflow_ai/features/drafts/draft_providers.dart';
import 'package:socialflow_ai/features/drafts/presentation/screens/drafts_screen.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  testWidgets('renders loading then empty states', (tester) async {
    final completer = Completer<List<Draft>>();
    final repository = _StubDraftRepository(() => completer.future);
    await _pump(tester, repository: repository);

    expect(find.byKey(const Key('drafts-loading')), findsOneWidget);
    completer.complete(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drafts-empty')), findsOneWidget);
    expect(find.text('Aucun brouillon'), findsOneWidget);
  });

  testWidgets('renders an error and reloads on retry', (tester) async {
    var shouldFail = true;
    final repository = _StubDraftRepository(() async {
      if (shouldFail) throw StateError('storage unavailable');
      return const [];
    });
    await _pump(tester, repository: repository);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drafts-error')), findsOneWidget);
    shouldFail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drafts-empty')), findsOneWidget);
    expect(repository.fetchCount, 2);
  });

  testWidgets('opens a draft and reports missing media without crashing', (
    tester,
  ) async {
    final draft = _draft(id: 'missing', mediaPaths: ['does-not-exist.jpg']);
    Draft? opened;
    await _pump(
      tester,
      repository: _StubDraftRepository(() async => [draft]),
      onOpen: (value) => opened = value,
    );
    await tester.pumpAndSettle();

    expect(find.text('1 média à remplacer'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('draft-card-missing')));
    await tester.pump();

    expect(opened, same(draft));
  });

  testWidgets('deletes only after confirmation', (tester) async {
    final draft = _draft(id: 'delete');
    final repository = _StubDraftRepository(() async => [draft]);
    await _pump(tester, repository: repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-draft-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer ce brouillon ?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-delete-draft')));
    await tester.pumpAndSettle();

    expect(repository.deletedIds, ['delete']);
    expect(find.byKey(const Key('drafts-empty')), findsOneWidget);
  });

  testWidgets('supports 320/390 widths in Light and Dark themes', (
    tester,
  ) async {
    final repository = _StubDraftRepository(
      () async => [
        _draft(
          id: 'responsive',
          mediaPaths: ['missing-one.jpg', 'missing-two.jpg'],
          platforms: const {SocialPlatform.instagram, SocialPlatform.linkedin},
        ),
      ],
    );

    for (final size in [const Size(320, 700), const Size(390, 844)]) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await _pump(
          tester,
          repository: repository,
          size: size,
          themeMode: mode,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('drafts-list')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('exposes open, delete and missing-media semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      repository: _StubDraftRepository(
        () async => [
          _draft(id: 'semantic', mediaPaths: ['missing.jpg']),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Reprendre le brouillon Publication texte')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Supprimer ce brouillon')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('1 média local indisponible')),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required DraftRepository repository,
  ValueChanged<Draft>? onOpen,
  Size size = const Size(390, 844),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [draftRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: DraftsScreen(onOpen: onOpen),
      ),
    ),
  );
}

Draft _draft({
  required String id,
  List<String> mediaPaths = const [],
  Set<SocialPlatform> platforms = const {},
}) => Draft(
  id: id,
  postType: PostType.text,
  sourceCaption: 'Idée de publication',
  mediaPaths: mediaPaths,
  selectedPlatforms: platforms,
  platformVariants: const {},
  createdAt: DateTime.utc(2026, 8, 10),
  updatedAt: DateTime.utc(2026, 8, 11),
);

class _StubDraftRepository implements DraftRepository {
  _StubDraftRepository(this._fetch);

  final Future<List<Draft>> Function() _fetch;
  final deletedIds = <String>[];
  var fetchCount = 0;

  @override
  Future<List<Draft>> fetchDrafts() {
    fetchCount++;
    return _fetch();
  }

  @override
  Future<Draft> saveDraft({required SocialPost post, String? draftId}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteDraft(String id) async {
    deletedIds.add(id);
  }
}
