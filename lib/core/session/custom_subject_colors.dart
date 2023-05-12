import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/custom_subject_color/custom_subject_color.dart';

class CustomSubjectColorsNotifier
    extends StateNotifier<Map<int, CustomSubjectColor>> {
  final int _userId;

  CustomSubjectColorsNotifier(this._userId) : super({});

  void add(CustomSubjectColor color) {
    state = Map.unmodifiable(Map.from(state)..addAll({color.subjectId: color}));
    saveToPrefs();
  }

  void remove(int id) {
    state = Map.unmodifiable(Map.from(state)..remove(id));
    saveToPrefs();
  }

  void reset() {
    state = Map.unmodifiable({});
    saveToPrefs();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_userId.custom_subject_colors',
      jsonEncode(
        state.values.map((e) => e.toJson()).toList(),
      ),
    );
  }

  Future<void> initializeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final customSubjectColors =
        prefs.getString('$_userId.custom_subject_colors');
    if (customSubjectColors != null) {
      state = Map.unmodifiable({
        for (var e in jsonDecode(customSubjectColors) as List)
          e['subjectId'] as int: CustomSubjectColor.fromJson(e)
      });
    }
  }
}

final customSubjectColorsProvider = StateNotifierProvider<
    CustomSubjectColorsNotifier, Map<int, CustomSubjectColor>>(
  (ref) {
    int userId = ref.watch(selectedSessionProvider.select((value) => value.userData!.id));
    return CustomSubjectColorsNotifier(userId);
  },
);
