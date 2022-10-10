import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/period_schedule.dart';
import 'package:your_schedule/ui/screens/home_screen/timetable_view.dart';
import 'package:your_schedule/ui/shared/my_drawer.dart';
import 'package:your_schedule/util/date_utils.dart';

enum ViewMode {
  week("Wochenansicht", Icons.calendar_view_week),
  day("Tagesansicht", Icons.calendar_view_day);

  final String readableName;
  final IconData icon;

  const ViewMode(this.readableName, this.icon);

  ///Get the opposite view mode
  ViewMode operator -() {
    return ViewMode.values[(index - 1).abs()];
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var viewMode = ref.watch(homeScreenViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              animateToDay(DateTime.now(), ref);
            },
            tooltip: "Zur jetzigen Woche springen",
          ),
          IconButton(
            onPressed: () {
              switchView(ref);
            },
            icon: Icon((-viewMode).icon),
            tooltip: "Zu ${(-viewMode).readableName} wechseln",
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: const TimeTableView(),
    );
  }

  Future<void> animateToDay(DateTime date, WidgetRef ref) async {
    ref.read(homeScreenDateProvider.state).state = date;
  }

  Future<void> switchView(WidgetRef ref) async {
    ref.read(homeScreenViewModeProvider.state).state =
        -ref.read(homeScreenViewModeProvider.state).state;
  }
}

final homeScreenDateProvider = StateProvider((ref) => DateTime.now());
final homeScreenViewModeProvider = StateProvider((ref) => ViewMode.week);

@immutable
class HomePageTimes {
  final TimeOfDay startOfDay;
  final TimeOfDay endOfDay;

  const HomePageTimes(this.startOfDay, this.endOfDay);

  HomePageTimes copyWith({
    TimeOfDay? startOfDay,
    TimeOfDay? endOfDay,
  }) {
    return HomePageTimes(
      startOfDay ?? this.startOfDay,
      endOfDay ?? this.endOfDay,
    );
  }
}

class HomePageTimesNotifier extends StateNotifier<HomePageTimes> {
  HomePageTimesNotifier()
      : super(
          HomePageTimes(
            PeriodSchedule.periodScheduleFallback.entries.first.startTime,
            PeriodSchedule.periodScheduleFallback.entries.first.endTime,
          ),
        );

  set maybeNewStartOfDay(TimeOfDay newStartOfDay) {
    ///We subtract the current time of day from the proposed time of day, and if this results in a negative number, we know that the proposed time of day is earlier than the current time of day.
    ///In that case, make the proposed time of day the new end of day.
    if (newStartOfDay.difference(state.startOfDay).isNegative) {
      state = state.copyWith(startOfDay: newStartOfDay);
    }
  }

  set maybeNewEndOfDay(TimeOfDay newEndOfDay) {
    ///We subtract the current time of day from the proposed time of day, and if this results in a negative number, we know that the proposed time of day is later than the current time of day.
    ///In that case, make the proposed time of day the new end of day.
    if (newEndOfDay.difference(state.endOfDay).isNegative) {
      state = state.copyWith(endOfDay: newEndOfDay);
    }
  }
}

final StateNotifierProvider<HomePageTimesNotifier, HomePageTimes>
    homePageTimesProvider =
    StateNotifierProvider((ref) => HomePageTimesNotifier());
