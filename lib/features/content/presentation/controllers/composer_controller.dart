import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/social_platform.dart';
import '../../data/repositories/local_content_repository.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(),
);
final composerControllerProvider =
    NotifierProvider<ComposerController, SocialPost>(ComposerController.new);

class ComposerController extends Notifier<SocialPost> {
  @override
  SocialPost build() => const SocialPost(
    type: PostType.image,
    caption: '',
    platforms: {},
    mediaPaths: [],
    mode: PublicationMode.draft,
  );

  void setType(PostType value) {
    if (state.type == value) return;
    state = state.copyWith(type: value, mediaPaths: const []);
  }

  void setCaption(String value) => state = state.copyWith(caption: value);
  void improveCaption() => setCaption(
    '5 astuces simples mais puissantes pour booster votre productivité chaque jour ! 🚀 Dites-moi celle que vous allez tester 👇',
  );
  void shortenCaption() => setCaption(
    '5 astuces pour booster votre productivité dès aujourd’hui 🚀',
  );
  void setMedia(List<String> paths) =>
      state = state.copyWith(mediaPaths: List.unmodifiable(paths));

  void addMedia(Iterable<String> paths) =>
      setMedia([...state.mediaPaths, ...paths]);

  void removeMediaAt(int index) {
    final paths = [...state.mediaPaths]..removeAt(index);
    setMedia(paths);
  }

  void replaceMediaAt(int index, String path) {
    final paths = [...state.mediaPaths]..[index] = path;
    setMedia(paths);
  }

  void moveMedia(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final paths = [...state.mediaPaths];
    final item = paths.removeAt(oldIndex);
    paths.insert(newIndex, item);
    setMedia(paths);
  }

  void togglePlatform(SocialPlatform platform) {
    final next = {...state.platforms};
    next.contains(platform) ? next.remove(platform) : next.add(platform);
    setPlatforms(next);
  }

  void setPlatforms(Set<SocialPlatform> platforms) =>
      state = state.copyWith(platforms: Set.unmodifiable(platforms));

  void setMode(PublicationMode value) => state = state.copyWith(mode: value);
  void schedule(DateTime date) =>
      state = state.copyWith(
        mode: PublicationMode.scheduled,
        scheduledAt: date,
      );

  Future<String> saveDraft() =>
      ref.read(contentRepositoryProvider).saveDraft(state);
  Future<String> publish() =>
      ref.read(contentRepositoryProvider).publish(state);
}
