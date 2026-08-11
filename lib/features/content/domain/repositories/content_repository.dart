import '../entities/social_post.dart';

abstract interface class ContentRepository {
  Future<String> publish(SocialPost post);
}
