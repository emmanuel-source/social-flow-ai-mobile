import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/content_repository.dart';

class LocalContentRepository implements ContentRepository {
  @override
  Future<String> publish(SocialPost post) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final id = 'post-${DateTime.now().millisecondsSinceEpoch}';
    await LocalStorage.drafts.put(id, {'status': 'published', 'caption': post.caption});
    return id;
  }

  @override
  Future<String> saveDraft(SocialPost post) async {
    final id = 'draft-${DateTime.now().millisecondsSinceEpoch}';
    await LocalStorage.drafts.put(id, {'status': 'draft', 'caption': post.caption, 'media': post.mediaPaths});
    return id;
  }
}
