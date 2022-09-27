import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_time_span.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

@immutable
class TimeTable {
  final List<CachedTimeTableWeekData> weekDataList;
  final PeriodSchedule periodSchedule;

  TimeTable(List<CachedTimeTableWeekData> weekDataList,
      [this.periodSchedule = PeriodSchedule.periodScheduleFallback])
      : weekDataList = List.unmodifiable(weekDataList);

  TimeTable copyWith({
    List<CachedTimeTableWeekData>? weekDataList,
    PeriodSchedule? periodSchedule,
  }) {
    return TimeTable(
      weekDataList ?? this.weekDataList,
      periodSchedule ?? this.periodSchedule,
    );
  }
}

class TimeTableNotifier extends StateNotifier<TimeTable> {
  TimeTableNotifier(this._userSession, this._ref) : super(TimeTable(const []));

  final UserSession _userSession;
  final StateNotifierProviderRef<TimeTableNotifier, TimeTable> _ref;

  void clearCache() {
    state = state.copyWith(weekDataList: const []);
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
    Future<CachedTimeTableWeekData> weekData = requestTimeTableTimeSpan(
            from, to)
        .then((value) => CachedTimeTableWeekData(from, to, relativeWeek, value),
            onError: (error, stackTrace) => getLogger()
                .e("Error while requesting timetable data", error, stackTrace))
      ..then((value) {
        state = state.copyWith(weekDataList: [...state.weekDataList, value]);
      });

    return weekData;
  }

  Future<TimeTableTimeSpan> requestTimeTableTimeSpan(DateTime from, DateTime to,
      {int personID = -1, PersonType personType = PersonType.unknown}) async {
    if (!_userSession.sessionIsValid) {
      throw Exception("Session is not valid");
    }

    return TimeTableTimeSpan.fromRPCResponse(
      from,
      to,
      await _ref.read(userSessionProvider.notifier).queryRPC(
        "getTimetable",
        {
          "options": {
            "startDate": from.convertToUntisDate,
            "endDate": to.convertToUntisDate(),
            "element": {
              "id": personID == -1
                  ? (_userSession.timeTablePersonID == -1
                      ? _userSession.loggedInPersonID
                      : _userSession.timeTablePersonID)
                  : personID,
              "type": (personType == PersonType.unknown
                      ? (_userSession.timeTablePersonType == PersonType.unknown
                          ? _userSession.loggedInPersonType.index
                          : _userSession.timeTablePersonType.index)
                      : personType.index) +
                  1,
            },
            "showLsText": true,
            "showPeText": true,
            "showStudentgroup": true,
            "showLsNumber": true,
            "showSubstText": true,
            "showInfo": true,
            "showBooking": true,
            "klasseFields": ['id', 'name', 'longname', 'externalkey'],
            "roomFields": ['id', 'name', 'longname', 'externalkey'],
            "subjectFields": ['id', 'name', 'longname', 'externalkey'],
            "teacherFields": ['id', 'name', 'longname', 'externalkey']
          }
        },
      ),
    );
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
    for (CachedTimeTableWeekData weekData in state.weekDataList) {
      if (weekData.startDate.isSameDay(from) &&
          weekData.endDate.isSameDay(to)) {
        return weekData;
      }
    }
    return null;
  }
}

final timeTableProvider =
    StateNotifierProvider<TimeTableNotifier, TimeTable>((ref) {
  return TimeTableNotifier(ref.watch(userSessionProvider), ref);
});
