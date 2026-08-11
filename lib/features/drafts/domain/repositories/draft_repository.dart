import '../../../content/domain/entities/social_post.dart';
import '../entities/draft.dart';

abstract interface class DraftRepository {
  Future<List<Draft>> fetchDrafts();

  Future<Draft> saveDraft({required SocialPost post, String? draftId});

  Future<void> deleteDraft(String id);
}
