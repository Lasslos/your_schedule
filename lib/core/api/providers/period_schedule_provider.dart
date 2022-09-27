import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/util/logger.dart';

class PeriodScheduleNotifier extends StateNotifier<PeriodSchedule> {
  final UserSession _userSession;
  final StateNotifierProviderRef<PeriodScheduleNotifier, PeriodSchedule> _ref;

  PeriodScheduleNotifier(this._userSession, this._ref)
      : super(PeriodSchedule.periodScheduleFallback);

  void setPeriodSchedule(PeriodSchedule periodSchedule) {
    state = periodSchedule;
  }

  Future<void> loadPeriodSchedule() async {
    if (!_userSession.isAPIAuthorized) {
      throw ApiConnectionError("The user is not logged in!");
    }
    try {
      http.Response response = await _ref
          .read(userSessionProvider.notifier)
          .queryURL("/WebUntis/api/rest/view/v1/timegrid",
              needsAuthorization: true);
      getLogger().i("Successfully fetched period schedule");
      state = PeriodSchedule.fromJSON(jsonDecode(response.body));
    } catch (e) {
      getLogger().e("Failed to fetch period schedule", e);
      rethrow;
    }
  }
}
