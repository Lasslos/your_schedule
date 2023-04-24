//ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/untis/rpc_request/rpc_response.dart';
import 'package:your_schedule/util/logger.dart';

part 'rpc_request.freezed.dart';

mixin DataField<T> {
  T get data;
}

mixin AuthenticationDetails {
  String get user;

  String get appSharedSecret;

  Map<String, dynamic> getAuthParamsJson() => {
        'auth': {
          'user': user,
          'token': OTP.generateTOTPCode(
              appSharedSecret, DateTime.now().millisecondsSinceEpoch ~/ 1000),
          'clientTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }
      };
}

@freezed
class UnauthenticatedRPCRequestScaffold
    with _$UnauthenticatedRPCRequestScaffold {
  const factory UnauthenticatedRPCRequestScaffold(Uri serverUrl) =
      _UnauthenticatedRPCRequestScaffold;
}

@freezed
class UnauthenticatedDataRPCRequestScaffold<T>
    with _$UnauthenticatedDataRPCRequestScaffold
    implements DataField<T> {
  const factory UnauthenticatedDataRPCRequestScaffold(
    Uri serverUrl,
    @protected T _data,
  ) = _UnauthenticatedDataRPCRequestScaffold<T>;

  const UnauthenticatedDataRPCRequestScaffold._();

  @override
  T get data => _data;
}

@freezed
class AuthenticatedRPCRequestScaffold
    with _$AuthenticatedRPCRequestScaffold, AuthenticationDetails {
  const factory AuthenticatedRPCRequestScaffold(
    Uri serverUrl,
    String user,
    String appSharedSecret,
  ) = _AuthenticatedRPCRequestScaffold;
}

@freezed
class AuthenticatedDataRPCRequestScaffold<T>
    with _$AuthenticatedDataRPCRequestScaffold, AuthenticationDetails
    implements DataField<T> {
  const factory AuthenticatedDataRPCRequestScaffold(
    Uri serverUrl,
    String user,
    String appSharedSecret,
    @protected T _data,
  ) = _AuthenticatedDataRPCRequestScaffold<T>;

  const AuthenticatedDataRPCRequestScaffold._();

  @override
  T get data => _data;
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
