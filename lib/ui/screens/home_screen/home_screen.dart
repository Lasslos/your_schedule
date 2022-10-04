import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/ui/screens/home_screen/timetable_view.dart';
import 'package:your_schedule/ui/shared/my_drawer.dart';

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
