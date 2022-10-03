import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/ui/shared/my_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomeScreenState();
}

enum ViewMode {
  week("Wochenansicht", Icons.calendar_view_week),
  day("Tagesansicht", Icons.calendar_today);

  final String readableName;
  final IconData icon;

  const ViewMode(this.readableName, this.icon);

  ///Get the opposite view mode
  ViewMode operator -() {
    return ViewMode.values[(index - 1).abs()];
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ViewMode viewMode = ViewMode.week;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                animateToWeek(Week.now());
              },
            ),
            IconButton(
              onPressed: () {
                switchView();
              },
              icon: Icon((-viewMode).icon),
              tooltip: "Zu ${(-viewMode).readableName} wechseln",
            ),
          ],
        ),
        drawer: const MyDrawer(),
        body: Center(
          child: Text('Dein Stundenplan - ${viewMode.readableName}'),
        ),
      );

  Future<void> animateToWeek(Week week) async {
    ///TODO
  }

  Future<void> switchView() async {
    setState(() {
      viewMode = -viewMode;
    });
  }
}
