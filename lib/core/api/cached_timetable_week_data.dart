import 'package:your_schedule/core/api/timetable_manager.dart';
import 'package:your_schedule/core/api/timetable_time_span.dart';
import 'package:your_schedule/core/api/user_session.dart';

///[CachedTimeTableWeekData] contains persistent information and is stored in the cache.
///This includes:
/// * Period Start and End
/// * Start of the week
/// * End of the week
/// * Index of the current week
class CachedTimeTableWeekData {
  final DateTime startDate;
  final DateTime endDate;

  final int relativeToCurrentWeek;

  final TimeTableManager manager;
  final UserSession activeSession;

  TimeTableTimeSpan? cachedWeekData;

  CachedTimeTableWeekData(this.startDate, this.endDate,
      this.relativeToCurrentWeek, this.manager, this.activeSession);

  Future<TimeTableTimeSpan> getWeekData(
      {bool reload = false,
      int personID = -1,
      PersonType personType = PersonType.unknown}) async {
    if (!reload && cachedWeekData != null) {
      return cachedWeekData!;
    }

    TimeTableTimeSpan timeSpan = await activeSession.getTimeTable(
        startDate, endDate, this,
        personID: personID, personType: personType);
    cachedWeekData = timeSpan;

    return timeSpan;
  }
}
