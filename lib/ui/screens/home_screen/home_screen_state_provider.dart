import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

@immutable
class HomeScreenState {
  final DateTime currentDate;
  final ViewMode viewMode;

  final TimeOfDay startOfDay;
  final TimeOfDay endOfDay;

  const HomeScreenState(
      this.currentDate, this.viewMode, this.startOfDay, this.endOfDay);

  HomeScreenState copyWith({
    DateTime? currentDate,
    ViewMode? viewMode,
    TimeOfDay? startOfDay,
    TimeOfDay? endOfDay,
  }) {
    return HomeScreenState(
      currentDate ?? this.currentDate,
      viewMode ?? this.viewMode,
      startOfDay ?? this.startOfDay,
      endOfDay ?? this.endOfDay,
    );
  }
}

class HomeScreenStateNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenStateNotifier()
      : super(
          HomeScreenState(
            DateTime.now(),
            ViewMode.week,
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 16, minute: 0),
          ),
        );

  set currentDate(DateTime date) => state = state.copyWith(currentDate: date);

  void switchView() => state = state.copyWith(viewMode: -state.viewMode);

  set startOfDay(TimeOfDay newStartOfDay) {
    if (newStartOfDay.difference(state.startOfDay).isNegative) {
      state = state.copyWith(startOfDay: newStartOfDay);
    }
  }

  set endOfDay(TimeOfDay newEndOfDay) {
    if (!newEndOfDay.difference(state.endOfDay).isNegative) {
      state = state.copyWith(endOfDay: newEndOfDay);
    }
  }
}

var homeScreenStateProvider =
    StateNotifierProvider<HomeScreenStateNotifier, HomeScreenState>(
        (ref) => HomeScreenStateNotifier());
