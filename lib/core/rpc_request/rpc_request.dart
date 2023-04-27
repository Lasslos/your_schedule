import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/rpc_request/rpc_response.dart';
import 'package:your_schedule/util/logger.dart';

part 'rpc_request.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class AuthParams with _$AuthParams {
  const factory AuthParams({
    required String user,
    required String appSharedSecret,
  }) = _AuthParams;

  Map<String, dynamic> toJson() => {
        'auth': {
          'user': user,
          'otp': OTP.generateTOTPCode(
            appSharedSecret.trim(),
            DateTime.now().millisecondsSinceEpoch,
            algorithm: Algorithm.SHA1,
            isGoogle: true,
          ),
          'clientTime': DateTime.now().millisecondsSinceEpoch,
        }
      };
}

int _id = 0;

///Posts a request to the Untis API and returns a Future<RPCResponse> as specified on [jsonrpc.org](https://www.jsonrpc.org/specification).
Future<RPCResponse> rpcRequest({
  required String method,
  required Uri serverUrl,
  dynamic params = const {},
}) async {
  int id = _id++;
  http.Response response;
  try {
    response = await http.post(
      serverUrl,
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': id.toString(),
        'method': method,
        if (params != null) 'params': params,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  } catch (e, s) {
    Sentry.captureException(
      e,
      stackTrace: s,
      hint: Hint.withMap(
        {
          'serverUrl': serverUrl.toString(),
          'method': method,
          'params': params,
        },
      ),
    );
    rethrow;
  }

  try {
    if (response.statusCode == 200) {
      var rpcResponse = RPCResponse.fromJson(jsonDecode(response.body));
      if (rpcResponse.id != id.toString()) {
        getLogger().wtf('id of response does not match id of request');
        throw Exception('id of response does not match id of request');
      }
      getLogger().i("Successful RPC Request: ${rpcResponse.toString()}");
      return rpcResponse;
    } else {
      getLogger()
          .e('HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
      throw HttpException(
        'HTTP Error: ${response.statusCode} ${response.reasonPhrase}',
        uri: serverUrl,
      );
    }
  } catch (e, s) {
    Sentry.captureException(
      e,
      stackTrace: s,
      hint: Hint.withMap(
        {
          'serverUrl': serverUrl.toString(),
          'method': method,
          'params': params,
        },
      ),
    );
    rethrow;
  }
}
