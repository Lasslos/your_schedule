import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/util/week.dart';

typedef TimeTableDay = List<TimeTablePeriod>;
typedef TimeTableWeek = Map<DateTime, TimeTableDay>;

class TimeTableNotifier extends StateNotifier<AsyncValue<TimeTableWeek>> {
  final Session _session;
  final Week _week;

  TimeTableNotifier(this._session, this._week) : super(const AsyncLoading()) {
    _load();
  }

  void _load() {
    _session.map(
      inactive: (inactiveSession) {
        state = AsyncData(Map.unmodifiable({}));
      },
      active: (activeSession) async {
        state = AsyncData(
          await requestTimeTable(
            _session.school.apiBaseUrl,
            activeSession.userData,
            AuthParams(
              user: _session.username,
              appSharedSecret: activeSession.appSharedSecret,
            ),
            _week,
          ),
        );
      },
    );
  }
}

final timeTableProvider = StateNotifierProvider.family<TimeTableNotifier, AsyncValue<TimeTableWeek>, Week>(
  (ref, week) {
    return TimeTableNotifier(ref.watch(selectedSessionProvider), week);
  }
);
