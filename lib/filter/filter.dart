import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/util/logger.dart';

class FilterItemsNotifier
    extends StateNotifier<Set<TimeTablePeriodSubjectInformation>> {
  FilterItemsNotifier() : super(<TimeTablePeriodSubjectInformation>{});

  //Hier wird versucht, die gespeicherten FilterItems aus dem Handy zu laden.
  Future<void> initialize() async {
    //Hier werden die FilterItems gespeichert.
    final prefs = await SharedPreferences.getInstance();
    List<String>? filterItemsAsString = prefs.getStringList("filterItems");
    if (filterItemsAsString == null) {
      return;
    }
    late List<TimeTablePeriodSubjectInformation> items;
    try {
      //Jedes FilterItem wird in ein TimeTablePeriodSubjectInformation Objekt umgewandelt.
      items = filterItemsAsString
          .map(
            (e) => TimeTablePeriodSubjectInformation.fromJSON(jsonDecode(e)),
          )
          .toList();
    } catch (e, s) {
      getLogger().w("JSON Parsing of FilterItems failed!", e, s);
      return;
    }
    state = Set.unmodifiable(items);
  }

  //Hier werden die FilterItems gespeichert.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "filterItems",
      state.map((e) => jsonEncode(e.toJSON())).toList(),
    );
  }

  void addItem(TimeTablePeriodSubjectInformation item) {
    state = Set.unmodifiable([...state, item]);
    save();
  }

  void removeItem(TimeTablePeriodSubjectInformation item) {
    state = Set.unmodifiable([...state]..remove(item));
    save();
  }

  //Mit dieser Methode werden alle Stunden herausgefiltert, welcer in der Liste von TimeTableWeeks sind.
  void filterEverything(List<TimeTablePeriod> periods) {
    state = Set.unmodifiable(
      periods.map((e) => e.subject),
    );
    save();
  }
}

final filterItemsProvider = StateNotifierProvider<FilterItemsNotifier,
    Set<TimeTablePeriodSubjectInformation>>(
  (ref) => FilterItemsNotifier(),
);
