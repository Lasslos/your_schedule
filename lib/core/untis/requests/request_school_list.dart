import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis/models/school_search/school.dart';

Future<List<School>> requestSchoolList(String query) async {
  final response = await rpcRequest(
    serverUrl: Uri.parse("https://schoolsearch.webuntis.com/schoolquery2"),
    method: "searchSchool",
    params: [
      {
        "search": query,
      }
    ],
  );

  return response.map(
    result: (result) {
      return result.result['schools'].map<School>((school) => School.fromJson(school)).toList();
    },
    error: (error) {
      throw error.error;
    },
  );
}
