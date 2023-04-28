import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/untis/models/app_shared_secret/app_shared_secret_params.dart';

Future<String> requestAppSharedSecret(
  String apiBaseUrl,
  String username,
  String password,
) async {
  var response = await rpcRequest(
    method: 'getAppSharedSecret',
    params: [
      AppSharedSecretParams(username: username, password: password).toJson()
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );
  return response.map(
    result: (result) {
      return result.result;
    },
    error: (error) {
      throw Exception(error.error);
    },
  );
}
