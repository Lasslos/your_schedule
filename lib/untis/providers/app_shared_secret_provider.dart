import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/untis/models/app_shared_secret/app_shared_secret_params.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';

final appSharedSecretProvider = FutureProvider.family<String,
        UnauthenticatedDataRPCRequestScaffold<AppSharedSecretParams>>(
    (ref, requestScaffold) async {
  var response = await rpcRequest(
    method: 'getAppSharedSecret',
    params: [requestScaffold.data.toJson()],
    serverUrl: requestScaffold.serverUrl,
  );
  return response.map(
    result: (result) {
      return result.result;
    },
    error: (error) {
      throw Exception(error.error);
    },
  );
});
