import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/session/timetable.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/day_view.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timegrid_widget.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/week_view.dart';
import 'package:your_schedule/util/week.dart';

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
        ref.invalidate(timeTableProvider(Week.fromDateTime(currentDate)));
      },
      child: TimeGridWidget(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: viewMode == ViewMode.day ? const DayView() : const WeekView(),
        ),
      ),
    );
  }
}
