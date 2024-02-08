import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/util/logger.dart';

class SessionsNotifier extends StateNotifier<List<UntisSession>> {
  SessionsNotifier() : super(List.unmodifiable([]));

  Future<void> addSession(UntisSession session) async {
    state = List.unmodifiable([session, ...state]);
    saveToSharedPrefs();
  }

  void removeSession(UntisSession session) {
    state = List.unmodifiable([...state]..remove(session));
    saveToSharedPrefs();
  }

  Future<void> removeSessionWhenDone(Future<dynamic> future, UntisSession session) async {
    try {
      await future;
    } catch (e) {
      getLogger().e(e);
    } finally {
      removeSession(session);
    }
  }

  void updateSession(UntisSession oldSession, UntisSession newSession) {
    //places the new session in the list at the same index as the old session
    //index of session is preserved
    state = List.unmodifiable(
      [...state].map(
        (e) => e == oldSession ? newSession : e,
      ),
    );
    saveToSharedPrefs();
  }

  set currentlyUsedSession(UntisSession session) {
    state = List.unmodifiable([
      session,
      ...[...state]..remove(session),
    ]);
    saveToSharedPrefs();
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<UntisSession>>(
  (ref) => SessionsNotifier(),
);
final selectedSessionProvider = Provider<UntisSession>(
  (ref) => ref.watch(sessionsProvider.select((value) => value[0])),
);

Future<UntisSession> activateSession(WidgetRef ref, UntisSession session) async {
  if (session is ActiveSession) {
    return session;
  }

  String appSharedSecret;
  UserData userData;
  try {
    appSharedSecret = await requestAppSharedSecret(session);
    userData = await requestUserData(
      session.school.rpcUrl,
      AuthParams(
        user: session.username,
        appSharedSecret: appSharedSecret,
      ),
    );
  } catch (e, s) {
    logRequestError("Error while requesting session data", e, s);
    rethrow;
  }
  return UntisSession.active(
    session.school,
    session.username,
    session.password,
    appSharedSecret,
    userData,
  );
}

Future<void> refreshSession(WidgetRef ref, UntisSession session) async {
  assert(session is ActiveSession, "Session must be active");
  var activeSession = session as ActiveSession;

  UserData userData;
  try {
    userData = await requestUserData(
      session.school.rpcUrl,
      AuthParams(
        user: activeSession.username,
        appSharedSecret: activeSession.appSharedSecret,
      ),
    );
  } catch (e, s) {
    logRequestError("Error while requesting session data", e, s);
    rethrow;
  }
  ref.read(sessionsProvider.notifier).updateSession(
        session,
        session.copyWith(userData: userData),
      );
}
