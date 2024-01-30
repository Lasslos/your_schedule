import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/utils.dart';

part 'rpc_request.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class AuthParams with _$AuthParams {
  const factory AuthParams({
    required String user,
    required String appSharedSecret,
  }) = _AuthParams;

  const AuthParams._();

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
        },
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
  Sentry.addBreadcrumb(
    Breadcrumb(
      message: 'Performing rpc request $method to $serverUrl',
      category: 'rpc.info',
      data: {
        'id': id,
        'method': method,
        if (params is List && params[0] is Map)
          'params': [...params][0]
            ..['auth'] = 'scrubbed'
            ..['password'] = "scrubbed"
            ..['userName'] = 'scrubbed',
      },
      level: SentryLevel.info,
    ),
  );
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
    getLogger().e("Error while performing rpcRequest $method to server $serverUrl", error: e, stackTrace: s);
    rethrow;
  }

  if (response.statusCode == 200) {
    var rpcResponse = RPCResponse.fromJson(jsonDecode(response.body));
    if (rpcResponse.id != id.toString()) {
      getLogger().f('id of response does not match id of request');
      throw const IllegalIdTokenException();
    }
    getLogger().i("Successful RPC Request: $method"
        "\n${rpcResponse.toStringNoResult()}");
    return rpcResponse;
  } else {
    getLogger().e(
      'HTTP Error: ${response.statusCode} ${response.reasonPhrase}',
      error: response,
      stackTrace: StackTrace.current,
    );
    throw HttpException(
      response.statusCode,
      response.reasonPhrase.toString(),
      uri: serverUrl,
    );
  }
}

class IllegalIdTokenException implements Exception {
  const IllegalIdTokenException();

  @override
  String toString() {
    return 'IllegalIdTokenException: id of response does not match id of request';
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;
  final Uri? uri;

  const HttpException(this.statusCode, this.message, {this.uri});

  @override
  String toString() {
    return 'HttpException: $message';
  }
}
