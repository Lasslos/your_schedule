import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/session/session.dart';

class FiltersNotifier extends StateNotifier<Set<int>> {
  final int _userId;

  FiltersNotifier(this._userId) : super({});

  void add(int id) {
    state = Set.unmodifiable(Set.from(state)..add(id));
    saveToPrefs();
  }

  void remove(int id) {
    state = Set.unmodifiable(Set.from(state)..remove(id));
    saveToPrefs();
  }

  void reset() {
    state = Set.unmodifiable({});
    saveToPrefs();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_userId.filters', jsonEncode(state.toList()));
  }

  Future<void> initializeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final filters = prefs.getString('$_userId.filters');
    if (filters != null) {
      state = Set.unmodifiable(
        (jsonDecode(filters) as List<dynamic>).map((e) => e as int).toSet(),
      );
    }
  }
}

final filtersProvider = StateNotifierProvider<FiltersNotifier, Set<int>>(
  (ref) {
    int userId = ref.watch(selectedSessionProvider).userData!.id;
    return FiltersNotifier(userId);
  },
);
