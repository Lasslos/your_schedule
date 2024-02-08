import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rpc_error.freezed.dart';
part 'rpc_error.g.dart';

@Freezed(fromJson: true, toJson: false)
class RPCError with _$RPCError {
  const factory RPCError(
    int code,
    String message,
    dynamic data,
  ) = _RPCError;

  const RPCError._();

  factory RPCError.fromJson(Map<String, dynamic> json) =>
      _$RPCErrorFromJson(json);

  @Deprecated('Use authenticationFailed instead')
  static const badCredentials = -8504;
  static const tooManyResults = -6003;
  static const invalidClientTime = -8524;
  static const authenticationFailed = -8998;
}
