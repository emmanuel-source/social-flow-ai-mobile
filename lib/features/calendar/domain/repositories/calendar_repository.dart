import '../entities/calendar_entry.dart';

abstract interface class CalendarRepository {
  Future<List<CalendarEntry>> fetchEntries();
}
