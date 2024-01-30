import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

typedef TimeTableDay = List<TimeTablePeriod>;
typedef TimeTableWeek = Map<Date, TimeTableDay>;

class TimeTableNotifier extends StateNotifier<AsyncValue<TimeTableWeek>> {
  final Session _session;
  final Week _week;
  final AsyncValue<ConnectivityResult> _connectivityResult;

  TimeTableNotifier(this._session, this._week, this._connectivityResult)
      : super(const AsyncLoading()) {
    _loadFromPrefs();
    _requestData();
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("${_session.userData?.id}.timetable.$_week")) {
      final json = jsonDecode(
        prefs.getString("${_session.userData?.id}.timetable.$_week")!,
      );
      state = AsyncData(
        {
          for (var entry in json.entries)
            Date.fromMillisecondsSinceEpoch(int.parse(entry.key)): entry.value
                .map<TimeTablePeriod>((e) => TimeTablePeriod.fromJson(e))
                .toList(),
        },
      );
    } else {
      state = AsyncData({
        for (var i = 0; i < 7; i++) _week.startDate.addDays(i): const [],
      });
      return;
    }
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> json = {
      for (var entry in state.requireValue.entries)
        entry.key.millisecondsSinceEpoch.toString():
            entry.value.map((e) => e.toJson()).toList(),
    };
    prefs.setString(
      "${_session.userData?.id}.timetable.$_week",
      jsonEncode(json),
    );
  }

  void _requestData() {
    _session.map(
      inactive: (inactiveSession) {},
      active: (activeSession) async {
        if (_connectivityResult is AsyncLoading) {
          return;
        }
        if (_connectivityResult.requireValue == ConnectivityResult.none) {
          return;
        }

        try {
          state = AsyncData(
            await requestTimeTable(
              _session.school.rpcUrl,
              activeSession.userData,
              AuthParams(
                user: _session.username,
                appSharedSecret: activeSession.appSharedSecret,
              ),
              _week,
            ),
          );
          _saveToPrefs();
        } catch (e, s) {
          state = AsyncError(e, s);
          logRequestError("Error while requesting timetable data", e, s);
        }
      },
    );
  }
}

final timeTableProvider = StateNotifierProvider.family<TimeTableNotifier,
    AsyncValue<TimeTableWeek>, Week>((ref, week) {
  return TimeTableNotifier(
    ref.watch(selectedSessionProvider),
    week,
    ref.watch(connectivityProvider),
  );
});
