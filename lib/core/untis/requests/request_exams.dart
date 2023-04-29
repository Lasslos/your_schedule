import 'package:intl/intl.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/untis/models/exams/exam.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

Future<Map<DateTime, List<Exam>>> requestExams(
  String apiBaseUrl,
  UserData userData,
  AuthParams authParams,
  Week week,
) async {
  var response = await rpcRequest(
    method: 'getExams2017',
    params: [
      {
        'id': userData.id,
        'type': userData.type,
        'startDate': DateFormat("yyyy-MM-dd").format(week.startDate),
        'endDate': DateFormat("yyyy-MM-dd").format(week.endDate),
        ...authParams.toJson(),
      }
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );

  return response.map(
    result: (result) {
      var examSet = (result.result['exams'] as List<dynamic>)
          .map((e) => Exam.fromJson(e))
          .toSet();
      var examMap = <DateTime, List<Exam>>{};
      for (var i = 0; i < 7; i++) {
        examMap[week.startDate.add(Duration(days: i))] = [];
      }
      for (var exam in examSet) {
        examMap[exam.startDateTime.normalized()]!.add(exam);
      }
      for (var i = 0; i < 7; i++) {
        examMap[week.startDate.add(Duration(days: i))]!
            .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      }
      return examMap;
    },
    error: (error) {
      throw error.error;
    },
  );
}
