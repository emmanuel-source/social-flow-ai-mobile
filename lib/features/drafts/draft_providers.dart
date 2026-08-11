import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/local_draft_repository.dart';
import 'domain/repositories/draft_repository.dart';

final draftRepositoryProvider = Provider<DraftRepository>(
  (ref) => LocalDraftRepository(),
);
