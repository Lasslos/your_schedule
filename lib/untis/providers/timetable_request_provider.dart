import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/untis/models/timetable/timetable_period.dart';
import 'package:your_schedule/untis/providers/user_data_reqeuest_provider.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

final timeTableRequestProvider = FutureProvider.autoDispose.family<Map<DateTime, List<TimeTablePeriod>>,
    AuthenticatedDataRPCRequestScaffold<Week>>((ref, requestScaffold) async {
  Week week = requestScaffold.data;
  var userData = await ref.watch(
    userDataRequestProvider(
      AuthenticatedRPCRequestScaffold(
        requestScaffold.serverUrl,
        requestScaffold.user,
        requestScaffold.appSharedSecret,
      ),
    ).future,
  );

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
        ...requestScaffold.getAuthParamsJson()
      }
    ],
    serverUrl: requestScaffold.serverUrl,
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
});
