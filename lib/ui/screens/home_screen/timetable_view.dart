import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/home_screen/pinch_to_zoom.dart';
import 'package:your_schedule/ui/screens/home_screen/two_dimensional_scroll_view.dart';

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
    var viewMode = ref.watch(homeScreenViewModeProvider);

    return PinchToZoom(
      child: viewMode == ViewMode.day ? const DayView() : const WeekView(),
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
    return const TwoDimensionalScrollView();
  }
}

class DayView extends ConsumerStatefulWidget {
  const DayView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  @override
  Widget build(BuildContext context) {
    return const TwoDimensionalScrollView();
  }
}
