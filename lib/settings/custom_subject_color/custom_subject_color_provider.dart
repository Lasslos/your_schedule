import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/settings/custom_subject_color/custom_subject_color.dart';
import 'package:your_schedule/util/logger.dart';

class CustomSubjectColorProvider
    extends StateNotifier<Map<int, CustomSubjectColor>> {
  CustomSubjectColorProvider() : super({});

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? customSubjectColorsAsString =
        prefs.getStringList("customSubjectColors");
    if (customSubjectColorsAsString == null) {
      return;
    }
    try {
      final items = customSubjectColorsAsString
          .map((e) => CustomSubjectColor.fromJson(jsonDecode(e)))
          .toList();
      state = Map.unmodifiable(
          {for (CustomSubjectColor e in items) e.subjectId: e});
    } catch (e, s) {
      getLogger().w("JSON Parsing of CustomSubjectColors failed!", e, s);
      return;
    }
  }

  //Hier werden die CustomSubjectColorItems gespeichert.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "customSubjectColors",
      state.values.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void addColor(int subject, Color color, Color textColor) {
    state = Map.unmodifiable(
      {...state, subject: CustomSubjectColor(subject, color, textColor)},
    );
    save();
  }

  void removeColor(int subject) {
    state = Map.unmodifiable({...state}..remove(subject));
    save();
  }

  void resetColors() {
    state = {};
    save();
  }
}

final customSubjectColorProvider = StateNotifierProvider<
    CustomSubjectColorProvider, Map<int, CustomSubjectColor>>(
  (ref) => CustomSubjectColorProvider(),
);
