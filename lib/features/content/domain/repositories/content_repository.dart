import '../entities/social_post.dart';

abstract interface class ContentRepository {
  Future<String> saveDraft(SocialPost post);
  Future<String> publish(SocialPost post);
}
