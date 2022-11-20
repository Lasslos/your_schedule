import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:your_schedule/util/logger.dart';

@immutable
class RPCResponse {
  static const rpcWrongCredentials = -8504;

  ///The app's name, as specified in the request.
  final String appName;

  ///Usually 2.0
  final String rpcVersion;

  final int httpStatusCode;

  final String? errorMessage;
  final int errorCode;

  final dynamic payload;
  final http.Response? originalResponse;

  bool get isApiError => errorMessage != null || errorCode != 0;

  bool get isHttpError => httpStatusCode != 200;

  bool get isError => isApiError || isHttpError;

  const RPCResponse(
    this.appName,
    this.rpcVersion,
    this.payload, [
    this.originalResponse,
    this.httpStatusCode = 200,
    this.errorMessage,
    this.errorCode = 0,
  ]);

  factory RPCResponse.fromResponseBody(String httpResponseBody) {
    return RPCResponse._combine(httpResponseBody, null);
  }

  factory RPCResponse.fromHttpResponse(http.Response httpResponse) {
    //Check status code
    if (httpResponse.statusCode != 200) {
      return RPCResponse(
        "unknown",
        "unknown",
        null,
        httpResponse,
        httpResponse.statusCode,
        "",
        0,
      );
    }

    return RPCResponse._combine(httpResponse.body, httpResponse);
  }

  ///[RPCResponse.fromResponseBody] and [RPCResponse.fromHttpResponse] both have a lot of logic in common, so this is a helper function to combine that logic
  factory RPCResponse._combine(
    String httpResponseBody, [
    http.Response? httpResponse,
  ]) {
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
      return RPCResponse(appId, rpcVersion, result, httpResponse, 200, null, 0);
    }

    //If there is no result, try to read an error
    var error = json['error'];
    if (error != null) {
      getLogger().w(
        "Error in RPCResponse: $error from request ${httpResponse?.request?.url.toString()}",
      );
      return RPCResponse(
        appId,
        rpcVersion,
        null,
        httpResponse,
        200,
        json['error']['message'],
        json['error']['code'],
      );
    }

    //If there is no result and no error, return an empty response
    getLogger().w(
      "Warning: Empty RPCResponse from request \n"
      "${httpResponse?.request.toString()}",
    );
    return RPCResponse(
      appId,
      rpcVersion,
      null,
      httpResponse,
      200,
      "empty response",
      -1,
    );
  }
}
