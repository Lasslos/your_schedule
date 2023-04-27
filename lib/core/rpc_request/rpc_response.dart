import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/rpc_request/rpc_error.dart';

part 'rpc_response.freezed.dart';

@Freezed(fromJson: false, toJson: false)
class RPCResponse with _$RPCResponse {
  @Assert('jsonrpc == "2.0"', 'jsonrpc must be exactly "2.0"')
  @Assert('result != null', 'result must not be null')
  const factory RPCResponse.result(
    @protected String jsonrpc,
    dynamic result,
    String id,
  ) = _RPCResponse;

  @Assert('jsonrpc == "2.0"', 'jsonrpc must be exactly "2.0"')
  @Assert('error != null', 'error must not be null')
  const factory RPCResponse.error(
    @protected String jsonrpc,
    RPCError error,
    String id,
  ) = _RPCResponseError;

  factory RPCResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return RPCResponse.error(
        json['jsonrpc'] as String,
        RPCError.fromJson(json['error'] as Map<String, dynamic>),
        json['id'] as String,
      );
    } else {
      return RPCResponse.result(
        json['jsonrpc'] as String,
        json['result'],
        json['id'] as String,
      );
    }
  }
}
