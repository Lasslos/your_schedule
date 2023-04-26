import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/app_shared_secret/app_shared_secret_params.dart';
import 'package:your_schedule/untis/models/school_search/school.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile(
    String username,
    String password,
    School school,
  ) = _UserProfile;

  const UserProfile._();

  UnauthenticatedDataRPCRequestScaffold<AppSharedSecretParams>
      get appSharedSecretParams => getUnauthenticatedDataRPCRequestScaffold(
            AppSharedSecretParams(
              username: username,
              password: password,
            ),
          );

  UnauthenticatedRPCRequestScaffold getUnauthenticatedRPCRequestScaffold() =>
      UnauthenticatedRPCRequestScaffold(
        Uri.parse(school.apiBaseUrl),
      );

  AuthenticatedRPCRequestScaffold getAuthenticatedRPCRequestScaffold(
          String appSharedSecret) =>
      AuthenticatedRPCRequestScaffold(
        Uri.parse(school.apiBaseUrl),
        username,
        appSharedSecret,
      );

  UnauthenticatedDataRPCRequestScaffold<T>
      getUnauthenticatedDataRPCRequestScaffold<T>(T data) =>
          UnauthenticatedDataRPCRequestScaffold<T>(
            Uri.parse(school.apiBaseUrl),
            data,
          );

  AuthenticatedDataRPCRequestScaffold<T>
      getAuthenticatedDataRPCRequestScaffold<T>(
              String appSharedSecret, T data) =>
          AuthenticatedDataRPCRequestScaffold<T>(
            Uri.parse(school.apiBaseUrl),
            username,
            appSharedSecret,
            data,
          );

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
