import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';

/// Requests the shared secret for the app.
///
/// The shared secret is used to authenticate the app with the server.
/// The request is send to [apiBaseUrl] and uses the [username] and [password] to authenticate.
/// Returns a [Future] with the shared secret. If authentication fails, a [RPCError] is thrown.
/// See [RPCError.authenticationFailed].
Future<String> requestAppSharedSecret(
  String apiBaseUrl,
  String username,
  String password,
) async {
  var response = await rpcRequest(
    method: 'getAppSharedSecret',
    params: [
      AppSharedSecretParams(username: username, password: password).toJson(),
    ],
    serverUrl: Uri.parse(apiBaseUrl),
  );
  return response.map(
    result: (result) {
      return result.result;
    },
    error: (error) {
      throw error.error;
    },
  );
}
