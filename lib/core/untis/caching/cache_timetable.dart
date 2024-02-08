import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/session/timetable.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

Future<TimeTableWeek> getCachedTimeTable(ActiveSession session, Week week) async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("${session.userData.id}.timetable.$week")) {
    return {
      for (var i = 0; i < 7; i++) week.startDate.addDays(i): const [],
    };
  }

  final json = jsonDecode(
    prefs.getString("${session.userData.id}.timetable.$week")!,
  );

  return {
    for (var entry in json.entries)
      Date.fromMillisecondsSinceEpoch(int.parse(entry.key)): entry.value.map<TimeTablePeriod>((e) => TimeTablePeriod.fromJson(e)).toList(),
  };
}

Future<void> setCachedTimeTable(ActiveSession session, Week week, TimeTableWeek timeTable) async {
  final prefs = await SharedPreferences.getInstance();

  Map<String, dynamic> json = {
    for (var entry in timeTable.entries) entry.key.millisecondsSinceEpoch.toString(): entry.value.map((e) => e.toJson()).toList(),
  };

  prefs.setString(
    "${session.userData.id}.timetable.$week",
    jsonEncode(json),
  );
}
