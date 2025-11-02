import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';

/// Requests the user data for the given user in [authParams].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
Future<UserData> requestUserData(
  UntisSession session,
  String appSharedSecret,
) async {
  var authParams = AuthParams(user: session.username, appSharedSecret: appSharedSecret);
  var response = await rpcRequest(
    method: 'getUserData2017',
    params: [
      {
        'elementId': 0,
        'deviceOs': 'AND',
        'deviceOsVersion': '',
        ...authParams.toJson(),
      }
    ],
    serverUrl: Uri.parse(session.school.rpcUrl),
  );

  return switch (response) {
    RPCResponseResult() => UserData.fromJson(response.result),
    RPCResponseError() => throw response.error,
  };
}
