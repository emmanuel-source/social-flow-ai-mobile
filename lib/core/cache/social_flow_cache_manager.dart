import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract final class SocialFlowCacheManager {
  static final CacheManager instance = CacheManager(
    Config(
      'socialflow_media_cache_v1',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 250,
    ),
  );
}
