import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/util/logger.dart';

class FilterItemsNotifier
    extends StateNotifier<List<TimeTablePeriodSubjectInformation>> {
  FilterItemsNotifier() : super([]);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? filterItemsAsString = prefs.getStringList("filterItems");
    if (filterItemsAsString == null) {
      return;
    }
    late List<TimeTablePeriodSubjectInformation> items;
    try {
      items = filterItemsAsString
          .map(
            (e) => TimeTablePeriodSubjectInformation.fromJSON(jsonDecode(e)),
          )
          .toList();
    } catch (e, s) {
      getLogger().w("JSON Parsing of FilterItems failed!", e, s);
      return;
    }
    state = List.unmodifiable(items);
  }

  void addItem(TimeTablePeriodSubjectInformation item) {
    getLogger().d("Setting new State");
    state = List.unmodifiable([...state, item]);
  }

  void removeItem(TimeTablePeriodSubjectInformation item) {
    state = List.unmodifiable([...state]..remove(item));
  }

  void clear() {
    state = List.unmodifiable([]);
  }
}

final filterItemsProvider = StateNotifierProvider<FilterItemsNotifier,
    List<TimeTablePeriodSubjectInformation>>(
  (ref) => FilterItemsNotifier(),
);
