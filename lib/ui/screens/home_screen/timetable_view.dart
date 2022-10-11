import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/period_layout.dart';
import 'package:your_schedule/ui/screens/home_screen/period_schedule_widget.dart';

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

    ref.listen(
      homeScreenStateProvider.select((value) => value.currentDate),
      (previous, next) {
        ///TODO: Check whether there is a need to animate to that date
      },
    );

    return RefreshIndicator(
      onRefresh: () {
        ///TODO: Refresh timetable
        return Future.delayed(const Duration(seconds: 1));
      },
      child: PeriodScheduleWidget(
        child: viewMode == ViewMode.week ? const WeekView() : const DayView(),
      ),
    );
  }

  Future<void> onRefresh() async {
    var timeTableProviderNotifier = ref.read(timeTableProvider.notifier);

    ///Cascading is not possible because of await
    // ignore: cascade_invocations
    timeTableProviderNotifier.clearCache();
    await timeTableProviderNotifier.getTimeTableWeek(Week.now());
  }
}

class WeekView extends ConsumerStatefulWidget {
  const WeekView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class DayView extends ConsumerWidget {
  const DayView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TimeTable timetable = ref.watch(timeTableProvider);
    List<TimeTablePeriod> periods = timetable
        .weekData[Week.now()]!.days.entries.first.value.periods.values
        .toList()
        .reduce((value, element) => [...value, ...element]);

    return PeriodLayout(
      periods: periods,
    );
  }
}
