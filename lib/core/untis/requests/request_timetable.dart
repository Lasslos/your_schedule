import 'package:intl/intl.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';
import 'package:your_schedule/util/date.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

/// Requests the timetable for the given [week].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
/// Returns a [Future] with a [Map] of [Date]s and [List]s of [TimeTablePeriod]s.
/// All [Date]s are normalized to the start of the day.
Future<Map<Date, List<TimeTablePeriod>>> requestTimeTable(
  String apiBaseUrl,
  UserData userData,
  AuthParams authParams,
  Week week,
) async {
  var response = await rpcRequest(
    method: 'getTimetable2017',
    params: [
      {
        'id': userData.id,
        'type': userData.type,
        'startDate': week.startDate.format(DateFormat('yyyy-MM-dd')),
        'endDate': week.endDate.format(DateFormat('yyyy-MM-dd')),
        'masterDataTimestamp': userData.timeStamp,
        'timetableTimestamp': 0,
        'timetableTimestamps': [],
        ...authParams.toJson(),
      }
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );

  return response.map(
    result: (result) {
      var timeTablePeriodList =
          (result.result['timetable']['periods'] as List<dynamic>)
              .map((e) => TimeTablePeriod.fromJson(e))
              .toList();
      var timeTablePeriodMap = <Date, List<TimeTablePeriod>>{};
      for (var i = 0; i < 7; i++) {
        timeTablePeriodMap[week.startDate.addDays(i)] = [];
      }
      for (var timeTablePeriod in timeTablePeriodList) {
        timeTablePeriodMap[timeTablePeriod.startTime.normalized()]!
            .add(timeTablePeriod);
      }
      for (var i = 0; i < 7; i++) {
        timeTablePeriodMap[week.startDate.addDays(i)]!.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      return timeTablePeriodMap;
    },
    error: (error) {
      throw error.error;
    },
  );
}
