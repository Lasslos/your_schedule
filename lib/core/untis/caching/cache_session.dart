import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/untis.dart';

Future<List<UntisSession>> getCachedSessions() async {
  final prefs = await SharedPreferences.getInstance();
  final sessions = prefs.getStringList('sessions');
  if (sessions == null || sessions.isEmpty) {
    return [];
  }
  return List.unmodifiable(
    sessions.map((e) => UntisSession.fromJson(jsonDecode(e))).toList(),
  );
}

Future<void> setCachedSessions(List<UntisSession> sessions) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList(
    'sessions',
    sessions.map((e) => jsonEncode(e.toJson())).toList(),
  );
}
