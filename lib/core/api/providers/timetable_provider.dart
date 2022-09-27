import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

@immutable
class TimeTable {
  final Map<Week, TimeTableWeek> weekData;
  final PeriodSchedule periodSchedule;

  TimeTable(Map<Week, TimeTableWeek> weekData,
      [this.periodSchedule = PeriodSchedule.periodScheduleFallback])
      : weekData = Map.unmodifiable(weekData);

  TimeTable copyWith({
    Map<Week, TimeTableWeek>? weekData,
    PeriodSchedule? periodSchedule,
  }) {
    return TimeTable(
      weekData ?? this.weekData,
      periodSchedule ?? this.periodSchedule,
    );
  }
}

class TimeTableNotifier extends StateNotifier<TimeTable> {
  TimeTableNotifier(this._userSession, this._ref) : super(TimeTable(const {}));

  final UserSession _userSession;
  final StateNotifierProviderRef<TimeTableNotifier, TimeTable> _ref;

  void clearCache() {
    state = state.copyWith(weekData: const {});
  }

  FutureOr<TimeTableWeek> getTimeTableWeek(Week week) {
    if (state.weekData.containsKey(week)) {
      return state.weekData[week]!;
    }
    getLogger().i("Fetching timetable for week $week");
    return _loadTimeTableWeek(week);
  }

  Future<TimeTableWeek> _loadTimeTableWeek(Week week,
      {int personID = -1, PersonType personType = PersonType.unknown}) async {
    if (!_userSession.sessionIsValid) {
      throw Exception("Session is not valid");
    }
    var timeTableWeek = TimeTableWeek.fromRPCResponse(
      week,
      await _ref.read(userSessionProvider.notifier).queryRPC(
        "getTimetable",
        {
          "options": {
            "startDate": week.startDate.convertToUntisDate(),
            "endDate": week.endDate.convertToUntisDate(),
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
    getLogger().i("Successfully fetched timetable for week $week");
    state = state.copyWith(
      weekData: Map.from(state.weekData)..[week] = timeTableWeek,
    );
    return timeTableWeek;
  }
}

final timeTableProvider =
    StateNotifierProvider<TimeTableNotifier, TimeTable>((ref) {
  return TimeTableNotifier(ref.watch(userSessionProvider), ref);
});
