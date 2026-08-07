import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/social_platform.dart';
import '../../data/repositories/local_content_repository.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) => LocalContentRepository());
final composerControllerProvider = NotifierProvider<ComposerController, SocialPost>(ComposerController.new);

class ComposerController extends Notifier<SocialPost> {
  @override
  SocialPost build() => const SocialPost(
        type: PostType.image,
        caption: 'Découvrez 5 astuces simples pour booster votre productivité au quotidien ! 🚀',
        platforms: {SocialPlatform.instagram, SocialPlatform.facebook, SocialPlatform.tiktok, SocialPlatform.youtube},
        mediaPaths: [],
        mode: PublicationMode.scheduled,
      );

  void setType(PostType value) => state = state.copyWith(type: value);
  void setCaption(String value) => state = state.copyWith(caption: value);
  void improveCaption() => setCaption('5 astuces simples mais puissantes pour booster votre productivité chaque jour ! 🚀 Dites-moi celle que vous allez tester 👇');
  void shortenCaption() => setCaption('5 astuces pour booster votre productivité dès aujourd’hui 🚀');
  void setMedia(List<String> paths) => state = state.copyWith(mediaPaths: paths);
  void togglePlatform(SocialPlatform platform) {
    final next = {...state.platforms};
    next.contains(platform) ? next.remove(platform) : next.add(platform);
    state = state.copyWith(platforms: next);
  }
  void setMode(PublicationMode value) => state = state.copyWith(mode: value);
  void schedule(DateTime date) => state = state.copyWith(mode: PublicationMode.scheduled, scheduledAt: date);

  Future<String> saveDraft() => ref.read(contentRepositoryProvider).saveDraft(state);
  Future<String> publish() => ref.read(contentRepositoryProvider).publish(state);
}
