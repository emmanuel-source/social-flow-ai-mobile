import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/domain/entities/social_post.dart';
import '../domain/entities/draft.dart';
import '../draft_providers.dart';

final draftsControllerProvider =
    AsyncNotifierProvider<DraftsController, List<Draft>>(DraftsController.new);

class DraftsController extends AsyncNotifier<List<Draft>> {
  @override
  Future<List<Draft>> build() =>
      ref.watch(draftRepositoryProvider).fetchDrafts();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(draftRepositoryProvider).fetchDrafts(),
    );
  }

  Future<Draft> save({required SocialPost post, String? draftId}) async {
    final repository = ref.read(draftRepositoryProvider);
    final saved = await repository.saveDraft(post: post, draftId: draftId);
    final current = state.value ?? await repository.fetchDrafts();
    final drafts = [
      saved,
      for (final draft in current)
        if (draft.id != saved.id) draft,
    ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    state = AsyncData(List.unmodifiable(drafts));
    return saved;
  }

  Future<void> delete(String id) async {
    try {
      await ref.read(draftRepositoryProvider).deleteDraft(id);
      final current = state.value ?? const <Draft>[];
      state = AsyncData(
        List.unmodifiable(current.where((draft) => draft.id != id)),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
