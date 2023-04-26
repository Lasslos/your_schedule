import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/util/logger.dart';

class FilterItemsNotifier extends StateNotifier<Set<int>> {
  FilterItemsNotifier() : super(<int>{});

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final filterItems = prefs.getStringList("filterItems");
    if (filterItems != null) {
      try {
        state = Set.unmodifiable(filterItems.map((e) => e as int));
      } catch (e, s) {
        getLogger().e("Error while loading filterItems", e, s);
        await Sentry.captureException(e, stackTrace: s);
      }
    }
  }

  //Hier werden die FilterItems gespeichert.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "filterItems",
      state.map((e) => e.toString()).toList(),
    );
  }

  void add(int subjectId) {
    state = Set.unmodifiable([...state, subjectId]);
    save();
  }

  void remove(int subjectId) {
    state = Set.unmodifiable([...state]..remove(subjectId));
    save();
  }

  //Mit dieser Methode werden alle Stunden herausgefiltert, welcher in der Liste von TimeTableWeeks sind.
  void setFiltered(Set<int> periods) {
    state = Set.unmodifiable(periods);
    save();
  }
}

final filterItemsProvider =
    StateNotifierProvider<FilterItemsNotifier, Set<int>>(
  (ref) => FilterItemsNotifier(),
);
