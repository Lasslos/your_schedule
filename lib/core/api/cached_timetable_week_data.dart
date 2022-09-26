import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/timetable_time_span.dart';
import 'package:your_schedule/core/api/user_session.dart';

///[CachedTimeTableWeekData] contains persistent information and is stored in the cache.
///This includes:
/// * Period Start and End
/// * Start of the week
/// * End of the week
/// * Index of the current week
@immutable
class CachedTimeTableWeekData {
  final DateTime startDate;
  final DateTime endDate;
  final int relativeToCurrentWeek;

  final TimeTableTimeSpan cachedWeekData;

  const CachedTimeTableWeekData(this.startDate, this.endDate,
      this.relativeToCurrentWeek, this.cachedWeekData);

  static Future<CachedTimeTableWeekData> getWeekData(
    UserSession activeSession,
    DateTime startDate,
    DateTime endDate,
    int relativeToCurrentWeek, {
    int personID = -1,
    PersonType personType = PersonType.unknown,
  }) async {
    TimeTableTimeSpan timeSpan = await activeSession.getTimeTable(
        startDate, endDate,
        personID: personID, personType: personType);
    return CachedTimeTableWeekData(
        startDate, endDate, relativeToCurrentWeek, timeSpan);
  }
}
