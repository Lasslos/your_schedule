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

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "filterItems",
      state.map((e) => jsonEncode(e.toJSON())).toList(),
    );
  }

  void addItem(TimeTablePeriodSubjectInformation item) {
    state = List.unmodifiable([...state, item]);
    save();
  }

  void removeItem(TimeTablePeriodSubjectInformation item) {
    state = List.unmodifiable([...state]..remove(item));
    save();
  }

  void clear() {
    state = List.unmodifiable([]);
    save();
  }
}

final filterItemsProvider = StateNotifierProvider<FilterItemsNotifier,
    List<TimeTablePeriodSubjectInformation>>(
  (ref) => FilterItemsNotifier(),
);
