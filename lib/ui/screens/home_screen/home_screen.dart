import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen_state_provider.dart';
import 'package:your_schedule/ui/screens/home_screen/timetable_view.dart';
import 'package:your_schedule/ui/shared/my_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var viewMode =
        ref.watch(homeScreenStateProvider.select((value) => value.viewMode));

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
    ref.read(homeScreenStateProvider.notifier);
  }

  Future<void> switchView(WidgetRef ref) async {
    ref.read(homeScreenStateProvider.notifier);

    ///TOOD
  }
}
