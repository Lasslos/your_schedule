import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:your_schedule/util/logger.dart';

@immutable
class RPCResponse {
  static const rpcWrongCredentials = -8504;

  ///Name der App
  final String appName;

  ///Normalerweise 2.0
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
    //Status Code prüfen
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

  ///[RPCResponse.fromResponseBody] und [RPCResponse.fromHttpResponse] sind beide ähnlich, diese Methode vereint sie.
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
    //Standardwerte lesen
    String appId = json['id'];
    String rpcVersion = json['jsonrpc'];

    //Daten lesen
    var result = json['result'];
    if (result != null) {
      return RPCResponse(appId, rpcVersion, result, httpResponse, 200, null, 0);
    }

    //Wenn es keine Daten gibt, prüfen, ob es einen Fehler gibt
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

    //Wenn es keine Daten und keine Fehler gibt, leere Antwort
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
