import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/utils.dart';

class ExamsNotifier extends StateNotifier<AsyncValue<Map<Date, List<Exam>>>> {
  final UntisSession _session;
  final Week _week;
  final AsyncValue<ConnectivityResult> _connectivityResult;

  ExamsNotifier(this._session, this._week, this._connectivityResult)
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
            await requestExams(
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
          logRequestError("Error while requesting exam data", e, s);
        }
      },
    );
  }
}

final examsProvider = StateNotifierProvider.family<ExamsNotifier, AsyncValue<Map<Date, List<Exam>>>, Week>((ref, week) {
  return ExamsNotifier(
    ref.watch(selectedSessionProvider),
    week,
    ref.watch(connectivityProvider),
  );
});
