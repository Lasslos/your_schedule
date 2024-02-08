import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';

part 'request_user_data.g.dart';

/// Requests the user data for the given user in [authParams].
///
/// The request is send to [apiBaseUrl] and uses the [authParams] to authenticate.
@riverpod
Future<UserData> requestUserData(RequestUserDataRef ref,
  String apiBaseUrl,
  AuthParams authParams,
) async {
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
    serverUrl: Uri.parse(apiBaseUrl),
  );

  return switch (response) {
    RPCResponseResult() => UserData.fromJson(response.result),
    RPCResponseError() => throw response.error,
  };
}
