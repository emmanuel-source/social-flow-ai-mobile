import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/social_platform.dart';
import '../../data/repositories/local_content_repository.dart';
import '../../domain/entities/platform_post_variant.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(),
);
final composerControllerProvider =
    NotifierProvider<ComposerController, SocialPost>(ComposerController.new);

class ComposerController extends Notifier<SocialPost> {
  @override
  SocialPost build() => _emptyPost;

  static const _emptyPost = SocialPost(
    type: PostType.image,
    caption: '',
    platforms: {},
    mediaPaths: [],
    mode: PublicationMode.draft,
  );

  /// Clears the active draft only after a completed publishing simulation.
  void reset() => state = _emptyPost;

  void setType(PostType value) {
    if (state.type == value) return;
    state = state.copyWith(type: value, mediaPaths: const []);
  }

  void setCaption(String value) {
    final previousSource = state.caption;
    final synchronized = <SocialPlatform, PlatformPostVariant>{
      for (final entry in state.platformVariants.entries)
        entry.key:
            entry.value.matchesSource(previousSource)
                ? PlatformPostVariant.fromSource(
                  platform: entry.key,
                  sourceCaption: value,
                )
                : entry.value,
    };
    state = state.copyWith(
      caption: value,
      platformVariants: Map.unmodifiable(synchronized),
    );
  }

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

  void setPlatforms(Set<SocialPlatform> platforms) {
    final variants = {...state.platformVariants};
    for (final platform in platforms) {
      variants.putIfAbsent(
        platform,
        () => PlatformPostVariant.fromSource(
          platform: platform,
          sourceCaption: state.caption,
        ),
      );
    }
    state = state.copyWith(
      platforms: Set.unmodifiable(platforms),
      platformVariants: Map.unmodifiable(variants),
    );
  }

  void initializePlatformVariants() => setPlatforms(state.platforms);

  void updatePlatformVariant(SocialPlatform platform, String caption) {
    if (!state.platforms.contains(platform)) return;
    final current = state.platformVariants[platform];
    final variant =
        current ??
        PlatformPostVariant.fromSource(
          platform: platform,
          sourceCaption: state.caption,
        );
    state = state.copyWith(
      platformVariants: Map.unmodifiable({
        ...state.platformVariants,
        platform: variant.copyWith(caption: caption),
      }),
    );
  }

  void resetPlatformVariant(SocialPlatform platform) {
    if (!state.platforms.contains(platform)) return;
    state = state.copyWith(
      platformVariants: Map.unmodifiable({
        ...state.platformVariants,
        platform: PlatformPostVariant.fromSource(
          platform: platform,
          sourceCaption: state.caption,
        ),
      }),
    );
  }

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
