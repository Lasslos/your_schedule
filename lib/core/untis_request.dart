import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:your_schedule/core/request_params/request_param.dart';

Future<void> test() async {
  var server = Server();
}

class UntisRequestData {
  String id;
  String jsonrpc;
  String method;
  List<RequestParam> params;

  UntisRequestData(this.method, this.params,
      {this.id = "-1", this.jsonrpc = "2.0"});
}
