import 'package:hive/hive.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../content/domain/entities/social_post.dart';
import '../../domain/entities/draft.dart';
import '../../domain/repositories/draft_repository.dart';
import '../models/draft_record.dart';

class LocalDraftRepository implements DraftRepository {
  LocalDraftRepository({
    Box<dynamic>? box,
    DateTime Function()? now,
    String Function(DateTime now)? createId,
  }) : _box = box ?? LocalStorage.drafts,
       _now = now ?? DateTime.now,
       _createId =
           createId ??
           ((value) => 'draft-${value.microsecondsSinceEpoch.toString()}');

  final Box<dynamic> _box;
  final DateTime Function() _now;
  final String Function(DateTime now) _createId;

  @override
  Future<List<Draft>> fetchDrafts() async {
    final drafts = <Draft>[];
    for (final value in _box.values) {
      if (!DraftRecord.isDraftRecord(value)) continue;
      drafts.add(DraftRecord.fromMap(value as Map<dynamic, dynamic>));
    }
    drafts.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return List.unmodifiable(drafts);
  }

  @override
  Future<Draft> saveDraft({required SocialPost post, String? draftId}) async {
    final timestamp = _now().toUtc();
    final id = draftId ?? _createId(timestamp);
    final existing = _box.get(id);
    final createdAt =
        existing is Map && DraftRecord.isDraftRecord(existing)
            ? DraftRecord.fromMap(existing).createdAt
            : timestamp;
    final draft = Draft(
      id: id,
      postType: post.type,
      sourceCaption: post.caption,
      mediaPaths: post.mediaPaths,
      selectedPlatforms: post.platforms,
      platformVariants: post.platformVariants,
      createdAt: createdAt,
      updatedAt: timestamp,
    );
    await _box.put(id, DraftRecord.toMap(draft));
    return draft;
  }

  @override
  Future<void> deleteDraft(String id) => _box.delete(id);
}
