import '../../../../shared/models/social_platform.dart';
import 'platform_post_variant.dart';

enum PostType { image, video, carousel, text }

enum PublicationMode { now, scheduled, draft }

class SocialPost {
  const SocialPost({
    required this.type,
    required this.caption,
    required this.platforms,
    required this.mediaPaths,
    required this.mode,
    this.platformVariants = const {},
    this.scheduledAt,
  });

  final PostType type;
  final String caption;
  final Set<SocialPlatform> platforms;
  final List<String> mediaPaths;
  final Map<SocialPlatform, PlatformPostVariant> platformVariants;
  final PublicationMode mode;
  final DateTime? scheduledAt;

  bool get hasValidSourceContent => switch (type) {
    PostType.text => caption.trim().isNotEmpty,
    PostType.image || PostType.video => mediaPaths.isNotEmpty,
    PostType.carousel => mediaPaths.length >= 2,
  };

  Map<SocialPlatform, PlatformPostVariant> get activePlatformVariants =>
      Map.unmodifiable({
        for (final platform in platforms)
          if (platformVariants[platform] case final variant?) platform: variant,
      });

  bool get hasValidPlatformVariants =>
      platforms.isNotEmpty &&
      hasValidSourceContent &&
      platforms.every((platform) {
        final variant = platformVariants[platform];
        if (variant == null) return false;
        return type != PostType.text || variant.caption.trim().isNotEmpty;
      });

  SocialPost copyWith({
    PostType? type,
    String? caption,
    Set<SocialPlatform>? platforms,
    List<String>? mediaPaths,
    Map<SocialPlatform, PlatformPostVariant>? platformVariants,
    PublicationMode? mode,
    DateTime? scheduledAt,
  }) {
    return SocialPost(
      type: type ?? this.type,
      caption: caption ?? this.caption,
      platforms: platforms ?? this.platforms,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      platformVariants: platformVariants ?? this.platformVariants,
      mode: mode ?? this.mode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }
}
