import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/untis/models/user_data/user_data.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';

final userDataProvider =
    FutureProvider.family<UserData, AuthenticatedRPCRequestScaffold>(
        (ref, requestScaffold) async {
  var response = await rpcRequest(
    method: 'getUserData2017',
    params: {
      'elementId': 0,
      'deviceOs': 'AND',
      'deviceOsVersion': '',
      ...requestScaffold.getAuthParamsJson()
    },
    serverUrl: requestScaffold.serverUrl,
  );
  return response.map(
    result: (result) {
      return UserData.fromJson(result.result);
    },
    error: (error) {
      throw Exception(error.error);
    },
  );
});
