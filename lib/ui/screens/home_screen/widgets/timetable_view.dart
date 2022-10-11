import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/day_view.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/period_schedule_widget.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/week_view.dart';

class TimeTableView extends ConsumerStatefulWidget {
  const TimeTableView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TimeTableViewState();
}

class _TimeTableViewState extends ConsumerState<TimeTableView> {
  @override
  Widget build(BuildContext context) {
    var viewMode =
        ref.watch(homeScreenStateProvider.select((value) => value.viewMode));

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(timeTableProvider.notifier).refresh();
      },
      child: PeriodScheduleWidget(
        child: viewMode == ViewMode.week ? const WeekView() : const DayView(),
      ),
    );
  }
}
