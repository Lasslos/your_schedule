import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/util/shared_preferences.dart';

part 'untis_session_provider.g.dart';

/// The first session is the currently used session.
@riverpod
class UntisSessions extends _$UntisSessions {
  @override
  List<UntisSession> build() {
    ref.listenSelf((prev, next) {
      if (prev != null) {
        _setCachedSessions(next);
      }
    });
    return _getCachedSessions();
  }

  void addSession(UntisSession session) {
    state = List.unmodifiable([session, ...state]);
  }

  void removeSession(UntisSession session) {
    state = List.unmodifiable([...state]..remove(session));
  }

  void removeSessionWhenDone(Future f, UntisSession session) {
    f.whenComplete(() => removeSession(session));
  }

  void updateSession(UntisSession oldSession, UntisSession newSession) {
    //places the new session in the list at the same index as the old session
    //index of session is preserved
    state = List.unmodifiable(
      state.map(
        (e) => e == oldSession ? newSession : e,
      ),
    );
  }

  set currentlyUsedSession(UntisSession session) {
    state = List.unmodifiable([
      session,
      ...[...state]..remove(session),
    ]);
  }

  List<UntisSession> _getCachedSessions() {
    final sessions = sharedPreferences.getStringList('sessions');
    if (sessions == null || sessions.isEmpty) {
      return [];
    }
    return List.unmodifiable(
      sessions.map((e) => UntisSession.fromJson(jsonDecode(e))).toList(),
    );
  }

  Future<void> _setCachedSessions(List<UntisSession> sessions) async {
    await sharedPreferences.setStringList(
      'sessions',
      sessions.map((e) => jsonEncode(e.toJson())).toList(),
    );
    state = sessions;
  }
}

@riverpod
UntisSession selectedUntisSession(SelectedUntisSessionRef ref) {
  return ref.watch(untisSessionsProvider.select((value) => value[0]));
}
