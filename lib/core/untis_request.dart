import 'dart:io';

import 'package:your_schedule/core/request_params/params.dart';

Future<HttpResponse> request() async {

}

class UntisRequestData {
  String id;
  String jsonrpc;
  String method;
  List<BaseParams> params;

  UntisRequestData(this.method,
      this.params,
      {
        this.id = "-1",
        this.jsonrpc = "2.0",
      });
}
