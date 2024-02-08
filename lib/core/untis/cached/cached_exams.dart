import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

part 'cached_exams.g.dart';

@riverpod
class CachedExams extends _$CachedExams {
  @override
  Future<Map<Date, List<Exam>>> build(ActiveUntisSession session, Week week) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("${session.userData.id}.exams.$week")) {
      return {
        for (var i = 0; i < 7; i++) week.startDate.addDays(i): const <Exam>[],
      };
    }

    final json = jsonDecode(prefs.getString("${session.userData.id}.exams.$week")!);

    return {
      for (var entry in json.entries) Date.fromMillisecondsSinceEpoch(int.parse(entry.key)): entry.value.map<Exam>((e) => Exam.fromJson(e)).toList(),
    };
  }

  Future<void> setCachedExams(Map<Date, List<Exam>> exams) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> json = {
      for (var entry in exams.entries) entry.key.millisecondsSinceEpoch.toString(): entry.value.map((e) => e.toJson()).toList(),
    };
    prefs.setString("${session.userData.id}.exams.$week", jsonEncode(json));
    state = AsyncValue.data(exams);
  }
}
