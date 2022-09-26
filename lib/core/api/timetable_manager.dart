import 'dart:async';

import 'package:your_schedule/core/api/models/helpers/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/user_session.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

class TimeTableManager {
  final UserSession userSession;
  List<CachedTimeTableWeekData> weekDataList = <CachedTimeTableWeekData>[];
  PeriodSchedule periodSchedule;

  TimeTableManager(this.userSession, [PeriodSchedule? periodSchedule])
      : periodSchedule =
            periodSchedule ?? PeriodSchedule.periodScheduleFallback;

  void clearCache() {
    weekDataList.clear();
  }

  /// Returns the start date of the week requested.
  /// [relativeToCurrentWeek] is the amount of weeks between this week and the desired week.
  /// Negative values mean weeks in the past, positive values mean weeks in the future.
  DateTime _getWeekStartDateRelativeToNow(int relativeWeek) {
    DateTime thisWeeksStartDate =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    return thisWeeksStartDate
        .add(Duration(days: relativeWeek * DateTime.daysPerWeek));
  }

  CachedTimeTableWeekData? _getCachedWeekData(DateTime from, DateTime to) {
    for (CachedTimeTableWeekData weekData in weekDataList) {
      if (weekData.startDate.isSameDay(from) &&
          weekData.endDate.isSameDay(to)) {
        return weekData;
      }
    }
    return null;
  }

  FutureOr<CachedTimeTableWeekData> getWeekDataRelativeToNow(int relativeWeek) {
    DateTime from = _getWeekStartDateRelativeToNow(relativeWeek).normalized();

    ///The sunday in the same week as the start date.
    DateTime to =
        from.add(Duration(days: DateTime.daysPerWeek - from.weekday + 1));

    CachedTimeTableWeekData? cachedWeekData = _getCachedWeekData(from, to);
    if (cachedWeekData != null) {
      return cachedWeekData;
    }
    Future<CachedTimeTableWeekData> weekData =
        CachedTimeTableWeekData.getWeekData(userSession, from, to, relativeWeek)
          ..then((value) => weekDataList.add(value),
              onError: (error, stackTrace) => getLogger().e(
                  "Error while requesting timetable data", error, stackTrace));
    return weekData;
  }
}

///TODO: Move this into a provider. Maybe even the same provider as user_session. This should not be a ChangeNotifierProvider, but instead a ValueNotifierProvider. That means: Extract all the variables, and then move the methods into the provider.
