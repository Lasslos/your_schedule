import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/day_view.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_schedule_widget.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/week_view.dart';

class TimeTableView extends ConsumerWidget {
  const TimeTableView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var viewMode = ref.watch(homeScreenStateProvider.select((value) => value.viewMode));

    return RefreshIndicator(
      onRefresh: () async {
        DateTime currentDate = ref.read(homeScreenStateProvider).currentDate;
        await ref.refresh(timeTableProvider(Week.fromDateTime(currentDate)).future);
        await ref.refresh(periodScheduleProvider.future);
      },
      child: PeriodScheduleWidget(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: viewMode == ViewMode.day ? const DayView() : const WeekView(),
        ),
      ),
    );
  }
}
