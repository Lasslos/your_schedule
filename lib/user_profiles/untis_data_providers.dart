import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/untis/models/app_shared_secret/app_shared_secret_params.dart';
import 'package:your_schedule/untis/providers/app_shared_secret_request_provider.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';
import 'package:your_schedule/user_profiles/user_profiles_provider.dart';

final appSharedSecretProvider = FutureProvider((ref) async {
  var selectedUser = ref.watch(userProfilesProvider.select((value) => value.selectedUserProfile));
  var params = UnauthenticatedDataRPCRequestScaffold<AppSharedSecretParams>(
    Uri.parse(selectedUser.school.apiBaseUrl),
    AppSharedSecretParams(
      username: selectedUser.username,
      password: selectedUser.password,
    ),
  );

  var appSharedSecret = ref.read(appSharedSecretRequestProvider(params));

});
