import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/social_platform.dart';
import '../../data/repositories/mock_calendar_repository.dart';
import '../../domain/entities/calendar_entry.dart';
import '../../domain/repositories/calendar_repository.dart';

enum CalendarViewMode { month, week, list }

class CalendarState {
  const CalendarState({
    required this.entries,
    required this.today,
    required this.focusedDate,
    required this.selectedDate,
    this.viewMode = CalendarViewMode.month,
    this.platform,
  });

  final List<CalendarEntry> entries;
  final DateTime today;
  final DateTime focusedDate;
  final DateTime selectedDate;
  final CalendarViewMode viewMode;
  final SocialPlatform? platform;

  List<CalendarEntry> get filteredEntries =>
      platform == null
          ? entries
          : entries.where((entry) => entry.platform == platform).toList();

  List<CalendarEntry> entriesFor(DateTime date) =>
      filteredEntries
          .where((entry) => isSameDay(entry.scheduledAt, date))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  CalendarState copyWith({
    DateTime? focusedDate,
    DateTime? selectedDate,
    CalendarViewMode? viewMode,
    SocialPlatform? platform,
    bool clearPlatform = false,
  }) => CalendarState(
    entries: entries,
    today: today,
    focusedDate: focusedDate ?? this.focusedDate,
    selectedDate: selectedDate ?? this.selectedDate,
    viewMode: viewMode ?? this.viewMode,
    platform: clearPlatform ? null : platform ?? this.platform,
  );

  static bool isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

final calendarClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return MockCalendarRepository(now: ref.watch(calendarClockProvider)());
});

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
      CalendarController.new,
    );

class CalendarController extends AsyncNotifier<CalendarState> {
  @override
  Future<CalendarState> build() async {
    final today = _dateOnly(ref.watch(calendarClockProvider)());
    final entries = await ref.watch(calendarRepositoryProvider).fetchEntries();
    return CalendarState(
      entries: entries,
      today: today,
      focusedDate: today,
      selectedDate: today,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void selectDate(DateTime date) => _update(
    (value) => value.copyWith(
      selectedDate: _dateOnly(date),
      focusedDate: _dateOnly(date),
    ),
  );

  void previousPeriod() => _movePeriod(-1);

  void nextPeriod() => _movePeriod(1);

  void goToToday() => _update(
    (value) =>
        value.copyWith(selectedDate: value.today, focusedDate: value.today),
  );

  void setViewMode(CalendarViewMode mode) =>
      _update((value) => value.copyWith(viewMode: mode));

  void setPlatform(SocialPlatform? platform) => _update(
    (value) =>
        value.copyWith(platform: platform, clearPlatform: platform == null),
  );

  void _movePeriod(int direction) => _update((value) {
    final next = switch (value.viewMode) {
      CalendarViewMode.month || CalendarViewMode.list => DateTime(
        value.focusedDate.year,
        value.focusedDate.month + direction,
        1,
      ),
      CalendarViewMode.week => value.focusedDate.add(
        Duration(days: DateTime.daysPerWeek * direction),
      ),
    };
    return value.copyWith(focusedDate: next, selectedDate: next);
  });

  void _update(CalendarState Function(CalendarState) transform) {
    final value = state.value;
    if (value != null) state = AsyncData(transform(value));
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
