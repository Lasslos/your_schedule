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

  factory RPCError.fromJson(Map<String, dynamic> json) =>
      _$RPCErrorFromJson(json);
}

const badCredentials = -8504;
const tooManyResults = -6003;
