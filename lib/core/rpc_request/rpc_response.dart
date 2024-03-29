import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';

part 'rpc_response.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class RPCResponse with _$RPCResponse {
  @Assert('jsonrpc == "2.0"', 'jsonrpc must be exactly "2.0"')
  @Assert('result != null', 'result must not be null')
  const factory RPCResponse.result(
    @protected String jsonrpc,
    dynamic result,
    String id,) = RPCResponseResult;

  @Assert('jsonrpc == "2.0"', 'jsonrpc must be exactly "2.0"')
  @Assert('error != null', 'error must not be null')
  const factory RPCResponse.error(
    @protected String jsonrpc,
    RPCError error,
    String id,) = RPCResponseError;

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

  const RPCResponse._();

  String toStringNoResult() => map(
        result: (result) =>
            'RPCResponse.result(jsonrpc: ${result.jsonrpc}, id: ${result.id}, result: (omitted)',
        error: (error) =>
            'RPCResponse.error(jsonrpc: ${error.jsonrpc}, id: ${error.id}, error: ${error.error})',
      );
}
