import '../../../../shared/models/social_platform.dart';
import '../../domain/entities/calendar_entry.dart';
import '../../domain/repositories/calendar_repository.dart';

class MockCalendarRepository implements CalendarRepository {
  MockCalendarRepository({
    DateTime? now,
    this.delay = const Duration(milliseconds: 350),
    List<CalendarEntry>? entries,
  }) : now = _dateOnly(now ?? DateTime.now()),
       _entries = entries;

  final DateTime now;
  final Duration delay;
  final List<CalendarEntry>? _entries;

  @override
  Future<List<CalendarEntry>> fetchEntries() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return List.unmodifiable(_entries ?? _buildDemoEntries());
  }

  List<CalendarEntry> _buildDemoEntries() {
    final tomorrow = now.add(const Duration(days: 1));
    final nextMonday = now.add(Duration(days: _daysUntilNextMonday(now)));
    final later = now.add(const Duration(days: 6));
    final yesterday = now.subtract(const Duration(days: 1));

    return [
      CalendarEntry(
        id: 'instagram-reel-today',
        scheduledAt: _at(now, 18, 30),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.instagram,
        contentType: CalendarContentType.reel,
        status: CalendarEntryStatus.scheduled,
        title: '3 idées pour créer sans s’épuiser',
        summary: 'Un Reel court avec trois conseils actionnables.',
        mediaUrl:
            'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=600',
      ),
      CalendarEntry(
        id: 'facebook-draft-today',
        scheduledAt: _at(now, 20, 0),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.facebook,
        contentType: CalendarContentType.image,
        status: CalendarEntryStatus.draft,
        title: 'Question à la communauté',
        summary: 'Brouillon à finaliser avant programmation.',
      ),
      CalendarEntry(
        id: 'tiktok-video-tomorrow',
        scheduledAt: _at(tomorrow, 10, 0),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.tiktok,
        contentType: CalendarContentType.video,
        status: CalendarEntryStatus.scheduled,
        title: 'Les coulisses du podcast #12',
        summary: 'Extrait vertical du prochain épisode.',
      ),
      CalendarEntry(
        id: 'linkedin-post-monday',
        scheduledAt: _at(nextMonday, 8, 15),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.linkedin,
        contentType: CalendarContentType.text,
        status: CalendarEntryStatus.pending,
        title: 'Les tendances social media à suivre',
        summary: 'Publication en attente de validation éditoriale.',
      ),
      CalendarEntry(
        id: 'youtube-video-later',
        scheduledAt: _at(later, 17, 45),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.youtube,
        contentType: CalendarContentType.video,
        status: CalendarEntryStatus.failed,
        title: 'Construire une stratégie durable',
        summary: 'La programmation doit être vérifiée.',
      ),
      CalendarEntry(
        id: 'instagram-published-yesterday',
        scheduledAt: _at(yesterday, 12, 0),
        timeZone: 'Europe/Paris',
        platform: SocialPlatform.instagram,
        contentType: CalendarContentType.carousel,
        status: CalendarEntryStatus.published,
        title: 'Checklist du créateur efficace',
      ),
    ];
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _at(DateTime day, int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  static int _daysUntilNextMonday(DateTime value) {
    final days = (DateTime.monday - value.weekday) % DateTime.daysPerWeek;
    return days == 0 ? DateTime.daysPerWeek : days;
  }
}
