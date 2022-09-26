//TimeTable Frame, Range, Manager
//New Names: CachedTimeTableData, TimeTableTimeSpan, TimeTableManager

import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/util/date_utils.dart';

@immutable
class TimeTableTimeSpan {
  final DateTime startDate;
  final DateTime endDate;

  final Map<DateTime, TimeTableDay> days = {};
  final int _maxDayLength = TimeTableDay.minHoursPerDay;

  int get maxDayLength => _maxDayLength;

  bool get isEmpty => days.isEmpty;


  TimeTableTimeSpan(
      // ignore: no_leading_underscores_for_local_identifiers
      DateTime _startDate,
      // ignore: no_leading_underscores_for_local_identifiers
      DateTime _endDate,
      RPCResponse response)
      : endDate = _endDate.normalized(),
        startDate = _startDate.normalized() {
    if (response.isError) {
      if (response.errorCode == -7004) {
        //"no allowed date"
        //create empty table
        if (!startDate.isAfter(endDate)) {
          throw Exception("The start date must be after the end date.");
        }

        for (int i = 0; i < endDate.difference(startDate).inDays; i++) {
          DateTime day = startDate.add(Duration(days: i));
          days[day] = TimeTableDay(day, i);
        }
        return;
      } else {
        throw Exception(
            "Error while loading timetable: ${response.statusMessage} (${response.errorCode})");
      }
    }

    if (!startDate.isAfter(endDate)) {
      throw Exception("The start date must be after the end date.");
    }

    ///Go through entries and put them into the days
    try {
      for (Map<String, dynamic> entry in response.payload) {
        DateTime entryDate = (entry['date']!.toString())
            .convertUntisDateToDateTime()
            .normalized();
        days[entryDate] = days
            .putIfAbsent(
                entryDate,
                () => TimeTableDay(
                      entryDate,
                      entryDate.difference(startDate).inDays,
                    ))
            .withPeriod(TimeTablePeriod.fromJSON(entry));
      }
    } catch (e) {
      debugPrint(
          "Error while loading timetable. Response JSON might be malformed.");
      rethrow;
    }

    ///Now go through all the days in the list and fill in those with no lessons
    ///Calculate the max day length and set the isEmpty flag
    for (int i = 0; i < endDate.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));
      days.putIfAbsent(
          date, () => TimeTableDay(date, i, isHolidayOrWeekend: true));
    }
  }
}
