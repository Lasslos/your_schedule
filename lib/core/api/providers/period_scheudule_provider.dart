import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';

class PeriodScheduleNotifier extends StateNotifier<PeriodSchedule> {
  PeriodScheduleNotifier() : super(PeriodSchedule.periodScheduleFallback);

  void setPeriodSchedule(PeriodSchedule periodSchedule) {
    state = periodSchedule;
  }

  ///TODO: Add method to request it from API
}
