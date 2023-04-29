import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/rpc_request/rpc_request.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/util/week.dart';

class ExamsNotifier extends StateNotifier<AsyncValue<Map<DateTime, List<Exam>>>> {
  final Session _session;
  final Week _week;

  ExamsNotifier(this._session, this._week) : super(const AsyncLoading()) {
    _load();
  }

  void _load() {
    _session.map(
      inactive: (inactiveSession) {
        state = AsyncData(Map.unmodifiable({}));
      },
      active: (activeSession) async {
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
      },
    );
  }
}

final examsProvider = StateNotifierProvider.family<ExamsNotifier, AsyncValue<Map<DateTime, List<Exam>>>, Week>(
  (ref, week) {
    return ExamsNotifier(ref.watch(selectedSessionProvider), week);
  }
);
