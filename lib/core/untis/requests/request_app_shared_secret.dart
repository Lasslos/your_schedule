import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';

/// Requests the shared secret for the app.
///
/// The shared secret is used to authenticate the app with the server.
/// Returns a [Future] with the shared secret. If authentication fails, a [RPCError] is thrown.
/// See [RPCError.authenticationFailed].
Future<String> requestAppSharedSecret(
  UntisSession session,
) async {
  var response = await rpcRequest(
    method: 'getAppSharedSecret',
    params: [
      AppSharedSecretParams(username: session.username, password: session.password).toJson(),
    ],
    serverUrl: Uri.parse(session.school.rpcUrl),
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
