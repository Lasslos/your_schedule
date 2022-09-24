import 'package:your_schedule/core/api/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/user_session.dart';
import 'package:your_schedule/util/date_utils.dart';

class TimeTableManager {
  final UserSession userSession;
  List<CachedTimeTableWeekData> weekDataList = <CachedTimeTableWeekData>[];
  PeriodSchedule periodSchedule;

  TimeTableManager(this.userSession, [PeriodSchedule? periodSchedule])
      : periodSchedule =
            periodSchedule ?? PeriodSchedule.periodScheduleFallback;

  void clearCache({bool hardReset = false}) {
    if (hardReset) {
      weekDataList.clear();
    } else {
      for (CachedTimeTableWeekData data in weekDataList) {
        data.cachedWeekData = null;
      }
    }
  }

  /// Returns the start date of the week requested.
  /// [relativeToCurrentWeek] is the amount of weeks between this week and the desired week.
  /// Negative values mean weeks in the past, positive values mean weeks in the future.
  DateTime _getRelativeToNowWeekStartDate(int relativeWeek) {
    DateTime thisWeeksStartDate =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    return thisWeeksStartDate
        .add(Duration(days: relativeWeek * DateTime.daysPerWeek));
  }

  CachedTimeTableWeekData? getCachedWeekData(DateTime from, DateTime to) {
    for (CachedTimeTableWeekData weekData in weekDataList) {
      if (weekData.startDate.isSameDay(from) &&
          weekData.endDate.isSameDay(to)) {
        return weekData;
      }
    }
    return null;
  }

  CachedTimeTableWeekData getRelativeToCurrentWeekData(int relativeWeek) {
    DateTime from = _getRelativeToNowWeekStartDate(relativeWeek).normalized();

    ///The sunday in the same week as the start date.
    DateTime to =
        from.add(Duration(days: DateTime.daysPerWeek - from.weekday + 1));

    CachedTimeTableWeekData? cachedWeekData = getCachedWeekData(from, to);
    if (cachedWeekData == null) {
      cachedWeekData =
          CachedTimeTableWeekData(from, to, relativeWeek, this, userSession);
      weekDataList.add(cachedWeekData);
    }
    return cachedWeekData;
  }
}
