import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/migration_core/timetable_period_subject_information.dart';
import 'package:your_schedule/util/logger.dart';

Set<TimeTablePeriodSubjectInformation> initializeFilters(SharedPreferences prefs) {
  List<String>? filterItemsAsString = prefs.getStringList("filterItems");
  if (filterItemsAsString == null) {
    return {};
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
    getLogger().w("JSON Parsing of FilterItems failed!", error: e, stackTrace: s);
    return {};
  }
  return Set.unmodifiable(items);
}
