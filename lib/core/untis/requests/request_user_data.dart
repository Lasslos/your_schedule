import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';

part 'request_user_data.g.dart';

/// Requests the user data for the given user in [authParams].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
@riverpod
Future<UserData> requestUserData(Ref ref,
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
