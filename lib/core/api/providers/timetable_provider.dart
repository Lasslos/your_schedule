import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

@immutable
class TimeTable {
  final Map<Week, TimeTableWeek> weekData;

  TimeTable(Map<Week, TimeTableWeek> weekData)
      : weekData = Map.unmodifiable(weekData);

  TimeTable copyWith({
    Map<Week, TimeTableWeek>? weekData,
  }) {
    return TimeTable(
      weekData ?? this.weekData,
    );
  }
}

class TimeTableNotifier extends StateNotifier<TimeTable> {
  TimeTableNotifier(this._userSession, this._ref) : super(TimeTable(const {}));

  final UserSession _userSession;
  final StateNotifierProviderRef<TimeTableNotifier, TimeTable> _ref;

  /// Only call this if the state for this week is null.
  Future<void> fetchTimeTableWeek(
    Week week, {
    int personID = -1,
    PersonType personType = PersonType.unknown,
  }) async {
    getLogger().i("Fetching timetable for week $week");
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
    // Check if the notifier is still mounted
    // If not, that means for some reason the Widget that requested this data was disposed
    // This can happen if the user navigates away from the page before the data is fetched
    // In that case, we don't want to update the state, because that would cause an error
    if (!mounted) {
      getLogger().w("Notifier is not mounted, aborting");
      throw Exception("Notifier is not mounted, aborting");
    }
    getLogger().i("Successfully fetched timetable for week $week");
    state = state.copyWith(
      weekData: Map.from(state.weekData)..[week] = timeTableWeek,
    );
  }

  Future<void> refresh([Week? week]) async {
    state = TimeTable(const {});
    week ??= Week.now();
    await fetchTimeTableWeek(week);
  }
}

final timeTableProvider =
    StateNotifierProvider<TimeTableNotifier, TimeTable>((ref) {
  return TimeTableNotifier(ref.watch(userSessionProvider), ref);
});

final filteredTimeTablePeriodsFamily = Provider.family<List<TimeTablePeriod>?, DateTime>((ref, date) {
  date = date.normalized();
  TimeTable timeTable = ref.watch(timeTableProvider);
  Set<TimeTablePeriodSubjectInformation> filterItems =
      ref.watch(filterItemsProvider);

  TimeTableWeek? timeTableWeek = timeTable.weekData[Week.fromDateTime(date)];
  if (timeTableWeek == null) {
    return null;
  }
  TimeTableDay day = timeTableWeek.days[date]!;

  return day.periods
      .where(
        (period) => !filterItems.contains(period.subject),
      )
      .toList();
});
