import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/calendar/data/repositories/mock_calendar_repository.dart';
import 'package:socialflow_ai/features/calendar/domain/entities/calendar_entry.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  final now = DateTime(2026, 8, 8);

  test('returns realistic entries relative to the injected date', () async {
    final entries =
        await MockCalendarRepository(
          now: now,
          delay: Duration.zero,
        ).fetchEntries();

    expect(entries, hasLength(6));
    expect(
      entries.any(
        (entry) =>
            entry.platform == SocialPlatform.instagram &&
            entry.scheduledAt == DateTime(2026, 8, 8, 18, 30),
      ),
      isTrue,
    );
  });

  test('supports multiple publications on the same day', () async {
    final entries =
        await MockCalendarRepository(
          now: now,
          delay: Duration.zero,
        ).fetchEntries();

    expect(
      entries.where((entry) => entry.scheduledAt.day == now.day),
      hasLength(2),
    );
  });

  test('covers all editorial statuses', () async {
    final entries =
        await MockCalendarRepository(
          now: now,
          delay: Duration.zero,
        ).fetchEntries();

    expect(entries.map((entry) => entry.status).toSet(), {
      ...CalendarEntryStatus.values,
    });
  });

  test('keeps scheduling timezone explicit', () async {
    final entries =
        await MockCalendarRepository(
          now: now,
          delay: Duration.zero,
        ).fetchEntries();

    expect(entries.every((entry) => entry.timeZone == 'Europe/Paris'), isTrue);
  });

  test('accepts injected entries for isolated UI states', () async {
    final repository = MockCalendarRepository(
      now: now,
      delay: Duration.zero,
      entries: const [],
    );

    expect(await repository.fetchEntries(), isEmpty);
  });
}
