import 'package:intl/intl.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

Future<Map<DateTime, List<TimeTablePeriod>>> requestTimetable(String apiBaseUrl,
    UserData userData, AuthParams authParams, Week week) async {
  var response = await rpcRequest(
    method: 'getTimetable2017',
    params: [
      {
        'id': userData.id,
        'type': userData.type,
        'startDate': DateFormat('yyyy-MM-dd').format(week.startDate),
        'endDate': DateFormat('yyyy-MM-dd').format(week.endDate),
        'masterDataTimestamp': userData.timeStamp,
        'timetableTimestamp': 0,
        'timetableTimestamps': [],
        ...authParams.toJson()
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
      var timeTablePeriodMap = <DateTime, List<TimeTablePeriod>>{};
      for (var i = 0; i < 7; i++) {
        timeTablePeriodMap[week.startDate.add(Duration(days: i))] = [];
      }
      for (var timeTablePeriod in timeTablePeriodList) {
        timeTablePeriodMap[timeTablePeriod.startTime.normalized()]!
            .add(timeTablePeriod);
      }
      for (var i = 0; i < 7; i++) {
        timeTablePeriodMap[week.startDate.add(Duration(days: i))]!
            .sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      return timeTablePeriodMap;
    },
    error: (error) {
      throw Exception(error.error);
    },
  );
}
