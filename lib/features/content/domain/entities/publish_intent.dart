import '../../../../shared/models/social_platform.dart';
import 'social_post.dart';

enum PublishMode { now, scheduled }

/// Immutable Flutter-side intent prepared for a future publishing backend.
///
/// It deliberately contains no provider response, remote identifier or OAuth
/// information. The [SocialPost] remains the source of content, media and
/// platform variants.
class PublishIntent {
  const PublishIntent._({
    required this.post,
    required this.mode,
    required this.timeZone,
    this.scheduledAt,
  });

  factory PublishIntent.now({
    required SocialPost post,
    required String timeZone,
  }) => PublishIntent._(post: post, mode: PublishMode.now, timeZone: timeZone);

  factory PublishIntent.scheduled({
    required SocialPost post,
    required DateTime scheduledAt,
    required String timeZone,
  }) => PublishIntent._(
    post: post,
    mode: PublishMode.scheduled,
    scheduledAt: scheduledAt,
    timeZone: timeZone,
  );

  final SocialPost post;
  final PublishMode mode;
  final DateTime? scheduledAt;
  final String timeZone;

  Set<SocialPlatform> get selectedPlatforms => post.platforms;
  bool get isScheduled => mode == PublishMode.scheduled;
}
