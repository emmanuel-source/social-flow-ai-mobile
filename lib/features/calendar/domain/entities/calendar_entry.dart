import '../../../../shared/models/social_platform.dart';

enum CalendarContentType { image, reel, video, carousel, text }

enum CalendarEntryStatus { draft, scheduled, pending, published, failed }

class CalendarEntry {
  const CalendarEntry({
    required this.id,
    required this.scheduledAt,
    required this.timeZone,
    required this.platform,
    required this.contentType,
    required this.status,
    required this.title,
    this.summary,
    this.mediaUrl,
  });

  final String id;
  final DateTime scheduledAt;
  final String timeZone;
  final SocialPlatform platform;
  final CalendarContentType contentType;
  final CalendarEntryStatus status;
  final String title;
  final String? summary;
  final String? mediaUrl;
}
