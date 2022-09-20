import 'package:your_schedule/core/api/timetable_manager.dart';
import 'package:your_schedule/core/api/timetable_time_span.dart';
import 'package:your_schedule/core/api/user_session.dart';

///[CachedTimetableWeekData] contains persistent information and is stored in the cache.
///This includes:
/// * Period Start and End
/// * Start of the week
/// * End of the week
/// * Index of the current week
class CachedTimetableWeekData {
  final DateTime startDate;
  final DateTime endDate;

  int? _weekIndex;
  final int relativeToCurrentWeek;

  final TimeTableManager manager;
  final UserSession activeSession;

  TimeTableTimeSpan? _cachedWeekData;

  CachedTimetableWeekData(this.startDate, this.endDate,
      this.relativeToCurrentWeek, this.manager, this.activeSession) {
    //TODO: What is current week and caculate week index!
  }

  Future<TimeTableTimeSpan> getWeekData(
      {bool reload = false,
      int personId = -1,
      PersonType personType = PersonType.unknown}) async {
    if (!reload && _cachedWeekData != null) {
      return _cachedWeekData!;
    }

    TimeTableTimeSpan timeSpan = await activeSession.getTimeTable(
        startDate, endDate, this,
        personId: personId, personType: personType);
    _cachedWeekData = timeSpan;

    return timeSpan;
  }

  ///TODO: This is somehow defined as the amount of weeks since the last school-free week but only the last five weeks otherwise its zero? idk man.
  ///Do we really need this for anything?
  Future<int?> getCurrentWeekIndex([bool concurrentSave = false]) async {
    if (_weekIndex != null) {
      return _weekIndex!;
    }

    int steps = -1;
    for (int i = relativeToCurrentWeek; i >= -5; i--, steps++) {
      TimeTableTimeSpan week = await manager
          .getFrameRelativeToCurrent(i, locked: concurrentSave)
          .getWeekData();
      if (week.isNonSchoolblockWeek()) {
        _weekIndex = steps;
        return steps;
      }
    }
    _weekIndex = null;
    return _weekIndex;
  }
}
