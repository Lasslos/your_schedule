import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:your_schedule/untis/models/exams/exam.dart';
import 'package:your_schedule/untis/providers/user_data_reqeuest_provider.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';
import 'package:your_schedule/util/week.dart';

final examRequestProvider =
    FutureProvider.autoDispose.family<Set<Exam>, AuthenticatedDataRPCRequestScaffold<Week>>(
  (ref, requestScaffold) async {
    final week = requestScaffold.data;
    final userData = await ref.watch(
      userDataRequestProvider(
        AuthenticatedRPCRequestScaffold(
          requestScaffold.serverUrl,
          requestScaffold.user,
          requestScaffold.appSharedSecret,
        ),
      ).future,
    );

    var response = await rpcRequest(
      method: 'getExams2017',
      params: [
        {
          'id': userData.id,
          'type': userData.type,
          'startDate': DateFormat("yyyy-MM-dd").format(week.startDate),
          'endDate': DateFormat("yyyy-MM-dd").format(week.endDate),
          ...requestScaffold.getAuthParamsJson()
        }
      ],
      serverUrl: requestScaffold.serverUrl,
    );

    return response.map(
      result: (result) {
        return (result.result['exams'] as List<dynamic>)
            .map((e) => Exam.fromJson(e))
            .toSet();
      },
      error: (error) {
        throw Exception(error.error);
      },
    );
  },
);
