import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_shared_secret_params.freezed.dart';
part 'app_shared_secret_params.g.dart';

@freezed
class AppSharedSecretParams with _$AppSharedSecretParams {
  const factory AppSharedSecretParams({
    required String userName,
    required String password,
  }) = _AppSharedSecretParams;

  factory AppSharedSecretParams.fromJson(Map<String, dynamic> json) =>
      _$AppSharedSecretParamsFromJson(json);
}
