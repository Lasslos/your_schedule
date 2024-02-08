import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/untis.dart';

Future<List<Session>> getCachedSessions() async {
  final prefs = await SharedPreferences.getInstance();
  final sessions = prefs.getStringList('sessions');
  if (sessions == null || sessions.isEmpty) {
    return [];
  }
  return List.unmodifiable(
    sessions.map((e) => Session.fromJson(jsonDecode(e))).toList(),
  );
}

Future<void> setCachedSessions(List<Session> sessions) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList(
    'sessions',
    sessions.map((e) => jsonEncode(e.toJson())).toList(),
  );
}
