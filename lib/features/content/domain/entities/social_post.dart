import '../../../../shared/models/social_platform.dart';

enum PostType { image, video, carousel, text }

enum PublicationMode { now, scheduled, draft }

class SocialPost {
  const SocialPost({
    required this.type,
    required this.caption,
    required this.platforms,
    required this.mediaPaths,
    required this.mode,
    this.scheduledAt,
  });

  final PostType type;
  final String caption;
  final Set<SocialPlatform> platforms;
  final List<String> mediaPaths;
  final PublicationMode mode;
  final DateTime? scheduledAt;

  SocialPost copyWith({
    PostType? type,
    String? caption,
    Set<SocialPlatform>? platforms,
    List<String>? mediaPaths,
    PublicationMode? mode,
    DateTime? scheduledAt,
  }) {
    return SocialPost(
      type: type ?? this.type,
      caption: caption ?? this.caption,
      platforms: platforms ?? this.platforms,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      mode: mode ?? this.mode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }
}
