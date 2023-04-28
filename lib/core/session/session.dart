import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/untis/untis_api.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
class Session with _$Session {
  const factory Session.active(
    School school,
    String username,
    String password,
    String appSharedSecret,
    UserData userData,
  ) = _ActiveSession;

  const factory Session.inactive({
    required School school,
    required String username,
    required String password,
    @Default(null) UserData? userData,
  }) = _InactiveSession;

  Session._();

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

class SessionsNotifier extends StateNotifier<List<Session>> {
  SessionsNotifier() : super(List.unmodifiable([]));

  Future<void> addSession(Session session) async {
    state = List.unmodifiable([session, ...state]);
    saveToSharedPrefs();
  }

  void removeSession(Session session) {
    state = List.unmodifiable([...state]..remove(session));
    saveToSharedPrefs();
  }

  void updateSession(Session oldSession, Session newSession) {
    var index = state.indexOf(oldSession);
    state = List.unmodifiable([...state]..setAll(index, [newSession]));
    saveToSharedPrefs();
  }

  set currentlyUsedSession(Session session) {
    state = List.unmodifiable([
      session,
      ...[...state]..remove(session)
    ]);
    saveToSharedPrefs();
  }

  Future<void> initializeFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sessions');
    if (sessions != null && sessions.isNotEmpty) {
      state = List.unmodifiable(
        sessions.map((e) => Session.fromJson(jsonDecode(e))).toList(),
      );
    } else {
      return;
    }
  }

  Future<void> saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'sessions', state.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<Session>>(
  (ref) => SessionsNotifier(),
);
final selectedSessionProvider = Provider<Session>(
  (ref) => ref.watch(sessionsProvider.select((value) => value[0])),
);

Future<Session> activateSession(WidgetRef ref, Session session) async {
  if (session is _ActiveSession) {
    return session;
  }

  var appSharedSecret = await requestAppSharedSecret(
    session.school.apiBaseUrl,
    session.username,
    session.password,
  );
  var userData = await requestUserData(
    session.school.apiBaseUrl,
    AuthParams(
      user: session.username,
      appSharedSecret: appSharedSecret,
    ),
  );
  return Session.active(
    session.school,
    session.username,
    session.password,
    appSharedSecret,
    userData,
  );
}
