import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/util/logger.dart';

class FilterItem {
  final TimeTablePeriodSchoolClassInformation schoolClass;
  final TimeTablePeriodTeacherInformation teacher;
  final TimeTablePeriodSubjectInformation subject;
  final TimeTablePeriodRoomInformation room;

  FilterItem(this.schoolClass, this.teacher, this.subject, this.room);

  bool matches(TimeTablePeriod period) {
    return schoolClass == period.schoolClass &&
        teacher == period.teacher &&
        subject == period.subject &&
        room == period.room;
  }

  Map<String, dynamic> toJSON() {
    return {
      "schoolClass": schoolClass.toJSON(),
      "teacher": teacher.toJSON(),
      "subject": subject.toJSON(),
      "room": room.toJSON(),
    };
  }

  factory FilterItem.fromJSON(Map<String, dynamic> json) {
    return FilterItem(
      TimeTablePeriodSchoolClassInformation.fromJSON(json["schoolClass"]),
      TimeTablePeriodTeacherInformation.fromJSON(json["teacher"]),
      TimeTablePeriodSubjectInformation.fromJSON(json["subject"]),
      TimeTablePeriodRoomInformation.fromJSON(json["room"]),
    );
  }
}

class FilterItemsNotifier extends StateNotifier<List<FilterItem>> {
  FilterItemsNotifier() : super([]);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? filterItemsAsString = prefs.getStringList("filterItems");
    if (filterItemsAsString == null) {
      return;
    }
    late List<FilterItem> items;
    try {
      items = filterItemsAsString.map(
            (e) => FilterItem.fromJSON(jsonDecode(e)),
      ).toList();
    } catch (e, s) {
      getLogger().w("JSON Parsing of FilterItems failed!", e, s);
      return;
    }
    state = List.unmodifiable(items);
  }

  void addItem(FilterItem item) {
    state = List.unmodifiable([...state, item]);
  }
  void removeItem(FilterItem item) {
    state = List.unmodifiable([...state]..remove(item));
  }
}

final filterItemsProvider = StateNotifierProvider<FilterItemsNotifier, List<FilterItem>>(
  (ref) => FilterItemsNotifier(),
);
