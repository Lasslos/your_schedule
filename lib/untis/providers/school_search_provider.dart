import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/untis/models/school_search/school.dart';
import 'package:your_schedule/untis/rpc_request/rpc_request.dart';

final schoolSearchProvider =
    FutureProvider.autoDispose.family<List<School>, String>((ref, query) async {
  final response = await rpcRequest(
    serverUrl: Uri.parse("https://mobile.webuntis.com/ms/schoolquery2/"),
    method: "searchSchool",
    params: [
      {
        "search": query,
      }
    ],
  );

  return response.map(
    result: (result) {
      return result.result['schools']
          .map<School>((school) => School.fromJson(school))
          .toList();
    },
    error: (error) {
      throw Exception(error.error);
    },
  );
});
