import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/provider/timetable_provider.dart';
import 'package:your_schedule/core/provider/untis_session_provider.dart';
import 'package:your_schedule/settings/view_mode_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_date_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/day_view.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/timegrid_widget.dart';
import 'package:your_schedule/ui/screens/home_screen/widgets/week_view.dart';
import 'package:your_schedule/utils.dart';

class TimeTableView extends ConsumerWidget {
  const TimeTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var viewMode = ref.watch(viewModeSettingProvider);
    var date = ref.watch(homeScreenDateProvider);

    return RefreshIndicator(
      onRefresh: () async {
        var session = ref.read(selectedUntisSessionProvider);
        ref.invalidate(timeTableProvider(session, Week.fromDate(date)));
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
