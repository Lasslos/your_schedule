import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';

part 'request_app_shared_secret.g.dart';

/// Requests the shared secret for the app.
///
/// The shared secret is used to authenticate the app with the server.
/// Returns a [Future] with the shared secret. If authentication fails, a [RPCError] is thrown.
/// See [RPCError.authenticationFailed].
@riverpod
Future<String> requestAppSharedSecret(RequestAppSharedSecretRef ref,
  UntisSession session,
) async {
  var response = await rpcRequest(
    method: 'getAppSharedSecret',
    params: [
      AppSharedSecretParams(username: session.username, password: session.password).toJson(),
    ],
    serverUrl: Uri.parse(session.school.rpcUrl),
  );

  return switch (response) {
    RPCResponseResult() => response.result,
    RPCResponseError() => throw response.error,
  };
}
