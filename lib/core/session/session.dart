import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/untis/models/exams/exam.dart';
import 'package:your_schedule/core/untis/models/school_search/school.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period.dart';
import 'package:your_schedule/core/untis/models/user_data/user_data.dart';
import 'package:your_schedule/core/untis/requests/request_app_shared_secret.dart';
import 'package:your_schedule/core/untis/requests/request_exams.dart';
import 'package:your_schedule/core/untis/requests/request_timetable.dart';
import 'package:your_schedule/core/untis/requests/request_user_data.dart';
import 'package:your_schedule/custom_subject_color/custom_subject_color.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/week.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class Session with _$Session, ChangeNotifier {
  const factory Session.active(
    School school,
    String username,
    String password,
    String appSharedSecret,
    UserData userData,
    @protected Map<DateTime, List<TimeTablePeriod>> timeTable,
    @protected Map<DateTime, List<Exam>> exams,
    @Immutable() Set<int> filterItems,
    @Immutable() Map<int, CustomSubjectColor> customSubjectColors,
  ) = _ActiveSession;

  const factory Session.inactive({
    required School school,
    required String username,
    required String password,
    @Default(null) UserData? userData,
    @protected @Default({}) Map<DateTime, List<TimeTablePeriod>> timeTable,
    @protected @Default({}) Map<DateTime, List<Exam>> exams,
    @Immutable() @Default({}) Set<int> filterItems,
    @Immutable() @Default({}) Map<int, CustomSubjectColor> customSubjectColors,
  }) = _InactiveSession;

  Session._();

  Future<Session> activate() async {
    if (this is _ActiveSession) {
      return this;
    }

    String appSharedSecret = await requestAppSharedSecret(
      school.apiBaseUrl,
      username,
      password,
    );
    UserData userData = await requestUserData(
      school.apiBaseUrl,
      AuthParams(
        user: username,
        appSharedSecret: appSharedSecret,
      ),
    );
    return Session.active(school, username, password, appSharedSecret, userData,
        timeTable, exams, filterItems, customSubjectColors);
  }

  Future<List<TimeTablePeriod>> getTimeTablePeriods(DateTime dateTime) async {
    dateTime = dateTime.normalized();
    if (timeTable.containsKey(dateTime)) {
      return timeTable[dateTime]!;
    }
    return map(
      inactive: (_) => [],
      active: (activeSession) async {
        Map<DateTime, List<TimeTablePeriod>> timeTablePeriods =
            await requestTimetable(
          activeSession.school.apiBaseUrl,
          activeSession.userData,
          AuthParams(
            user: activeSession.username,
            appSharedSecret: activeSession.appSharedSecret,
          ),
          Week.fromDateTime(dateTime),
        );
        timeTable.addAll(timeTablePeriods);
        notifyListeners();
        return timeTable[dateTime]!;
      },
    );
  }

  Future<List<TimeTablePeriod>> refreshTimeTablePeriods(DateTime dateTime) {
    if (this is _InactiveSession) {
      throw Exception('No active session, cannot refresh');
    }
    timeTable[dateTime] = [];
    return getTimeTablePeriods(dateTime);
  }

  Future<List<Exam>> getExams(DateTime dateTime) async {
    dateTime = dateTime.normalized();
    if (exams.containsKey(dateTime)) {
      return exams[dateTime]!;
    }
    return map(
      inactive: (_) => [],
      active: (activeSession) async {
        Map<DateTime, List<Exam>> exams = await requestExams(
          activeSession.school.apiBaseUrl,
          activeSession.userData,
          AuthParams(
            user: activeSession.username,
            appSharedSecret: activeSession.appSharedSecret,
          ),
          Week.fromDateTime(dateTime),
        );
        exams.addAll(exams);
        notifyListeners();
        return exams[dateTime]!;
      },
    );
  }

  Future<List<Exam>> refreshExams(DateTime dateTime) {
    if (this is _InactiveSession) {
      throw Exception('No active session, cannot refresh');
    }
    exams[dateTime] = [];
    return getExams(dateTime);
  }

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

class SessionsNotifier extends StateNotifier<List<Session>> {
  SessionsNotifier() : super(List.unmodifiable([]));

  Future<void> addSession(Session session) async {
    session = await session.activate()
      ..addListener(_onSessionChange);
    state = List.unmodifiable([...state, session]);
    saveToSharedPrefs();
  }

  void removeSession(Session session) {
    state = List.unmodifiable([...state]..remove(session));
    session.removeListener(_onSessionChange);
    saveToSharedPrefs();
  }

  set currentlyUsedSession(Session session) {
    state = List.unmodifiable([
      session,
      ...[...state]..remove(session)
    ]);
    saveToSharedPrefs();
  }

  void addFilter(Session session, int filter) {
    session = session.copyWith(filterItems: session.filterItems..add(filter));
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  void removeFilter(Session session, int filter) {
    session =
        session.copyWith(filterItems: session.filterItems..remove(filter));
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  void setFilters(Session session, Set<int> filters) {
    session = session.copyWith(filterItems: filters);
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  void addCustomSubjectColor(
      Session session, int subjectId, CustomSubjectColor color) {
    session = session.copyWith(
        customSubjectColors: session.customSubjectColors..[subjectId] = color);
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  void removeCustomSubjectColor(Session session, int subjectId) {
    session = session.copyWith(
        customSubjectColors: session.customSubjectColors..remove(subjectId));
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  void resetCustomSubjectColors(Session session) {
    session = session.copyWith(customSubjectColors: {});
    state = List.unmodifiable([...state]..[state.indexOf(session)] = session);
    saveToSharedPrefs();
  }

  Future<void> initializeFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sessions');
    if (sessions != null && sessions.isNotEmpty) {
      state = List.unmodifiable(
          sessions.map((e) => Session.fromJson(jsonDecode(e))).toList());
    } else {
      return;
    }
    state[0].activate();
  }

  Future<void> saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'sessions', state.map((e) => jsonEncode(e.toJson())).toList());
  }

  void _onSessionChange() {
    state = state;
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<Session>>(
    (ref) => SessionsNotifier());
final selectedSessionProvider = Provider<Session>(
    (ref) => ref.watch(sessionsProvider.select((value) => value[0])));
