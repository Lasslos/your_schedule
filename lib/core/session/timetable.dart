import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/provider/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

typedef TimeTableDay = List<TimeTablePeriod>;
typedef TimeTableWeek = Map<Date, TimeTableDay>;

class TimeTableNotifier extends StateNotifier<AsyncValue<TimeTableWeek>> {
  final UntisSession _session;
  final Week _week;
  final AsyncValue<ConnectivityResult> _connectivityResult;

  TimeTableNotifier(this._session, this._week, this._connectivityResult)
      : super(const AsyncLoading()) {
    _loadFromPrefs();
    _requestData();
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
