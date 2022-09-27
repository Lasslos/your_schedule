import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

@immutable
class RPCResponse {
  static const rpcWrongCredentials = -8504;

  ///The app's name, as specified in the request.
  final String appName;

  ///Usually 2.0
  final String rpcVersion;

  final String statusMessage;

  ///Zero means no error.
  final int errorCode;
  final int httpResponse;
  final dynamic payload;

  bool get isApiError =>
      statusMessage.isNotEmpty &&
      (payload is Map<String, dynamic> ? payload.isNotEmpty : true);

  bool get isHttpError =>
      (payload is Map<String, dynamic> ? payload.isEmpty : true) &&
      statusMessage == "http error";

  bool get isError => isApiError || isHttpError;

  final http.Response? originalResponse;

  const RPCResponse(this.appName, this.rpcVersion, this.payload,
      [this.statusMessage = "",
      this.errorCode = 0,
      this.httpResponse = -1,
      this.originalResponse]);

  factory RPCResponse.fromResponseBody(String httpResponseBody) {
    return RPCResponse._combine(httpResponseBody, null);
  }

  factory RPCResponse.fromHttpResponse(http.Response httpResponse) {
    //Check status code
    if (httpResponse.statusCode != 200) {
      return RPCResponse("", "", const <String, dynamic>{}, "http error", 0,
          httpResponse.statusCode, httpResponse);
    }

    return RPCResponse._combine(httpResponse.body, httpResponse);
  }

  ///[RPCResponse.fromResponseBody] and [RPCResponse.fromHttpResponse] both have a lot of logic in common, so this is a helper function to combine that logic
  factory RPCResponse._combine(String httpResponseBody,
      [http.Response? httpResponse]) {
    Map<String, dynamic> json = {};
    try {
      json = jsonDecode(httpResponseBody);
    } catch (e) {
      log("Warning: Error while decoding JSON: $e");
    }
    //Read standard information
    String appId = json['id'];
    String rpcVersion = json['jsonrpc'];

    //Read data
    var result = json['result'];
    if (result != null) {
      return RPCResponse(appId, rpcVersion, result, "", 0, 200, httpResponse);
    }

    //If there is no result, try to read an error
    var error = json['error'];
    if (error != null) {
      return RPCResponse(
          appId,
          rpcVersion,
          const <String, dynamic>{},
          json['error']['message'],
          json['error']['code'],
          httpResponse?.statusCode ?? -1,
          httpResponse);
    }

    //If there is no result and no error, return an empty response
    return RPCResponse(appId, rpcVersion, const <String, dynamic>{}, "", 0,
        httpResponse?.statusCode ?? -1, httpResponse);
  }
}
