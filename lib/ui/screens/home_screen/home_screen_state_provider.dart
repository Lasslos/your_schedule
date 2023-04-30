import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/util/date_utils.dart';

enum ViewMode {
  week("Wochenansicht", Icons.calendar_view_week),
  day("Tagesansicht", Icons.calendar_view_day);

  final String readableName;
  final IconData icon;

  const ViewMode(this.readableName, this.icon);

  ///Der gegenteilige ViewMode
  ViewMode operator -() {
    return ViewMode.values[(index - 1).abs()];
  }
}

//Hier wird gespeichert, welche Ansicht gerade angezeigt wird und welcher Tag ausgewählt ist.
@immutable
class HomeScreenState {
  final DateTime currentDate;
  final ViewMode viewMode;

  HomeScreenState(
    DateTime currentDate,
    this.viewMode,
  ) : currentDate = currentDate.normalized();

  HomeScreenState copyWith({
    DateTime? currentDate,
    ViewMode? viewMode,
  }) {
    return HomeScreenState(
      currentDate ?? this.currentDate,
      viewMode ?? this.viewMode,
    );
  }
}

class HomeScreenStateNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenStateNotifier()
      : super(
          HomeScreenState(
            DateTime.now(),
            ViewMode.day,
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    int viewModeInt = prefs.getInt("viewMode") ?? 1;
    ViewMode viewMode = ViewMode.values[viewModeInt];
    state = state.copyWith(viewMode: viewMode);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("viewMode", state.viewMode.index);
  }

  set currentDate(DateTime date) => state = state.copyWith(currentDate: date);

  void switchView() {
    state = state.copyWith(viewMode: -state.viewMode);
    _save();
  }
}

var homeScreenStateProvider =
    StateNotifierProvider<HomeScreenStateNotifier, HomeScreenState>(
  (ref) => HomeScreenStateNotifier(),
);
