import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/provider/untis_session_provider.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/util/logger.dart';

part 'untis_session.freezed.dart';
part 'untis_session.g.dart';

@freezed
sealed class UntisSession with _$UntisSession {
  const factory UntisSession.active(
    School school,
    String username,
    String password,
    String token,
    String appSharedSecret,
    UserData userData,
  ) = ActiveUntisSession;

  const factory UntisSession.inactive({
    required School school,
    required String username,
    required String password,
    required String token,
  }) = InactiveUntisSession;

  factory UntisSession.fromJson(Map<String, dynamic> json) => _$UntisSessionFromJson(json);
}

Future<ActiveUntisSession> activateSession(WidgetRef ref, UntisSession session) async {
  String appSharedSecret;
  UserData userData;

  try {
    appSharedSecret = await ref.read(requestAppSharedSecretProvider(session).future);
    userData = await ref.read(requestUserDataProvider(session, appSharedSecret).future);
  } catch (e, s) {
    logRequestError("Error while requesting session data", e, s);
    rethrow;
  }
  var activeSession = UntisSession.active(
    session.school,
    session.username,
    session.password,
    session.token,
    appSharedSecret,
    userData,
  ) as ActiveUntisSession;
  ref.read(untisSessionsProvider.notifier).updateSession(session, activeSession);
  return activeSession;
}

Future<ActiveUntisSession> refreshSession(WidgetRef ref, ActiveUntisSession session) async {
  UserData userData;
  try {
    userData = await ref.read(requestUserDataProvider(session, session.appSharedSecret).future);
  } catch (e, s) {
    logRequestError("Error while requesting session data", e, s);
    rethrow;
  }
  var refreshedSession = session.copyWith(userData: userData);
  ref.read(untisSessionsProvider.notifier).updateSession(
        session,
        refreshedSession,
      );
  return refreshedSession;
}
