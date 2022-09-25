//TimeTable Frame, Range, Manager
//New Names: CachedTimeTableData, TimeTableTimeSpan, TimeTableManager

import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/cached_timetable_week_data.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/util/date_utils.dart';

class TimeTableTimeSpan {
  final DateTime startDate;
  final DateTime endDate;

  final Map<DateTime, TimeTableDay> days = {};
  int _maxDayLength = TimeTableDay.minHoursPerDay;

  int get maxDayLength => _maxDayLength;

  bool _isEmpty = true;

  bool get isEmpty => _isEmpty;

  final CachedTimeTableWeekData weekData;

  TimeTableTimeSpan(
      // ignore: no_leading_underscores_for_local_identifiers
      DateTime _startDate,
      DateTime _endDate,
      this.weekData,
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
          days[day] = TimeTableDay(day, this, i);
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
        days
            .putIfAbsent(
                entryDate,
                () => TimeTableDay(
                    entryDate, this, entryDate.difference(startDate).inDays))
            .insertPeriod(
                (timeSpan) => TimeTablePeriod.fromJSON(entry, timeSpan));
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
      var day = days.putIfAbsent(
          date, () => TimeTableDay(date, this, i)..isHolidayOrWeekend = true);

      if (day.hours.length > _maxDayLength) {
        _maxDayLength = day.hours.length;
      }

      if (day.hours.isNotEmpty) {
        _isEmpty = false;
      }

      //TODO: Ich habe den x und y index einfach mal gekonnt ausgelassen, weil die schultage so nicht funktionieren.
      //Es gibt nicht eine klasse pro stunde, und dinge wie klausuren sind ganz außerhalb des [PeriodSchedule], also müssen wir das mit den listen eh nochmal überarbeiten
      // und einen index kann es dann eh nicht mehr geben.
    }
  }
}
