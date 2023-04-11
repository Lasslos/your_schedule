import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

final timeTableProvider = FutureProvider.family<TimeTableWeek, Week>((ref, week) async {
  UserSession userSession = ref.watch(userSessionProvider);
  getLogger().i("Fetching timetable for week $week");
  if (!userSession.sessionIsValid) {
    return TimeTableWeek(week, const {});
  }
  var timeTableWeek = TimeTableWeek.fromRPCResponse(
    week,
    await ref.read(userSessionProvider.notifier).queryRPC(
      "getTimetable",
      {
        "options": {
          "startDate": week.startDate.convertToUntisDate(),
          "endDate": week.endDate.convertToUntisDate(),
          "element": {
            "id": userSession.timeTablePersonID != -1
                ? userSession.timeTablePersonID
                : userSession.loggedInPersonID,
            "type": userSession.timeTablePersonType != PersonType.unknown
                ? userSession.timeTablePersonType.index
                : userSession.loggedInPersonType.index
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
  return timeTableWeek;
});

final filteredTimeTablePeriodsProvider = FutureProvider.family<List<TimeTablePeriod>, DateTime>((ref, date) async {
  TimeTableWeek timeTableWeek = await ref.watch(timeTableProvider(Week.fromDateTime(date)).future);
  Set<TimeTablePeriodSubjectInformation> filterItems = ref.watch(filterItemsProvider);
  TimeTableDay day = timeTableWeek.days[date.normalized()]!;

  return day.periods
    .where(
      (period) => !filterItems.contains(period.subject),
    ).toList();
});
