import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:your_schedule/util/logger.dart';

class CustomSubjectColor {
  final TimeTablePeriodSubjectInformation subject;
  final Color color;
  final Color textColor;

  CustomSubjectColor(this.subject, this.color, this.textColor);

  CustomSubjectColor.fromJSON(Map<String, dynamic> json)
      : subject = TimeTablePeriodSubjectInformation.fromJSON(json["subject"]),
        color = Color(json["color"]),
        textColor = Color(json["textColor"]);

  Map<String, dynamic> toJSON() => {
        "subject": subject.toJSON(),
        "color": color.value,
        "textColor": textColor.value,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomSubjectColor &&
          runtimeType == other.runtimeType &&
          subject == other.subject &&
          color == other.color &&
          textColor == other.textColor;

  @override
  int get hashCode => Object.hash(subject, color, textColor);

  static final CustomSubjectColor regularColor = CustomSubjectColor(
    const TimeTablePeriodSubjectInformation("", "", 0),
    Colors.lightGreen,
    Colors.white,
  );
  static final CustomSubjectColor irregularColor = CustomSubjectColor(
    const TimeTablePeriodSubjectInformation("", "", 0),
    Colors.orange,
    Colors.white,
  );
  static final CustomSubjectColor cancelledColor = CustomSubjectColor(
    const TimeTablePeriodSubjectInformation("", "", 0),
    Colors.red,
    Colors.white,
  );
  static final CustomSubjectColor emptyColor = CustomSubjectColor(
    const TimeTablePeriodSubjectInformation("", "", 0),
    Colors.grey,
    Colors.black,
  );
}

class CustomSubjectColorProvider extends StateNotifier<
    Map<TimeTablePeriodSubjectInformation, CustomSubjectColor>> {
  CustomSubjectColorProvider() : super({});

  //Hier wird versucht, die gespeicherten CustomSubjectColorItems aus dem Handy zu laden.
  Future<void> initialize() async {
    //Hier werden die CustomSubjectColorItems gespeichert.
    final prefs = await SharedPreferences.getInstance();
    List<String>? customSubjectColorsAsString =
        prefs.getStringList("customSubjectColors");
    if (customSubjectColorsAsString == null) {
      return;
    }
    late List<CustomSubjectColor> items;
    try {
      items = customSubjectColorsAsString
          .map(
            (e) => CustomSubjectColor.fromJSON(jsonDecode(e)),
          )
          .toList();
    } catch (e, s) {
      getLogger().w("JSON Parsing of CustomSubjectColors failed!", e, s);
      return;
    }
    //Hier wird der state auf die CustomSubjectColorItems gesetzt.
    state = Map.unmodifiable(
        Map.fromEntries(items.map((e) => MapEntry(e.subject, e))),
    );
  }

  //Hier werden die CustomSubjectColorItems gespeichert.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "customSubjectColors",
      state.values.map((e) => jsonEncode(e.toJSON())).toList(),
    );
  }

  void addColor(TimeTablePeriodSubjectInformation subject, Color color, Color textColor) {
    state = Map.unmodifiable(
      {...state, subject: CustomSubjectColor(subject, color, textColor)},
    );
    save();
  }

  void removeColor(TimeTablePeriodSubjectInformation subject) {
    state = Map.unmodifiable({...state}..remove(subject));
    save();
  }

  void resetColors() {
    state = {};
    save();
  }
}

final customSubjectColorProvider = StateNotifierProvider<
    CustomSubjectColorProvider,
    Map<TimeTablePeriodSubjectInformation, CustomSubjectColor>>(
  (ref) => CustomSubjectColorProvider(),
);
