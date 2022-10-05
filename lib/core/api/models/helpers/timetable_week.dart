import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/util/date_utils.dart';

@immutable
class TimeTableWeek {
  final Week week;
  final Map<DateTime, TimeTableDay> days;
  final int maxDayLength = TimeTableDay.minHoursPerDay;

  bool get isEmpty => days.isEmpty;

  TimeTableWeek(this.week, Map<DateTime, TimeTableDay> days)
      : days = Map.unmodifiable(days);

  factory TimeTableWeek.fromRPCResponse(Week week, RPCResponse response) {
    final Map<DateTime, TimeTableDay> days = {};

    if (response.isError) {
      if (response.errorCode == -7004) {
        //"no allowed date"
        //create empty table
        for (int i = 0; i < 7; i++) {
          DateTime day = week.startDate.add(Duration(days: i));
          days[day] = TimeTableDay(day, i);
        }
        return TimeTableWeek(week, days);
      } else {
        throw Exception(
          "Error while loading timetable: ${response.errorMessage} (${response.errorCode})",
        );
      }
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
                entryDate.difference(week.startDate).inDays,
              ),
            )
            .withPeriod(
              TimeTablePeriod.fromJSON(entry),
            );
      }
    } catch (e) {
      debugPrint(
        "Error while loading timetable. Response JSON might be malformed.",
      );
      rethrow;
    }

    ///Now go through all the days in the list and fill in those with no lessons
    ///Calculate the max day length and set the isEmpty flag
    for (int i = 0; i < 7; i++) {
      DateTime date = week.startDate.add(Duration(days: i));
      days.putIfAbsent(
        date,
        () => TimeTableDay(date, i, isHolidayOrWeekend: true),
      );
    }
    return TimeTableWeek(week, days);
  }
}

@immutable
class Week {
  final DateTime startDate;
  final DateTime endDate;

  int get relativeToCurrentWeek =>
      startDate.startOfWeek().difference(DateTime.now().startOfWeek()).inDays ~/
      7;

  ///Constructs a week object the given [momentInWeek] is in.
  Week(DateTime momentInWeek)
      : startDate = momentInWeek.startOfWeek(),
        endDate = momentInWeek.endOfWeek();

  Week.now() : this(DateTime.now());

  Week.relativeToCurrentWeek(int relative)
      : startDate =
            DateTime.now().startOfWeek().add(Duration(days: relative * 7)),
        endDate = DateTime.now().endOfWeek().add(Duration(days: relative * 7));

  List<DateTime> get daysInWeek => [for (int i = 0; i < 7; i++) startDate.add(Duration(days: i))];

  @override
  int get hashCode => Object.hash(startDate, endDate);

  @override
  bool operator ==(Object other) {
    if (other is! Week) {
      return false;
    }
    return startDate.isAtSameMomentAs(other.startDate) &&
        endDate.isAtSameMomentAs(other.endDate);
  }

  @override
  String toString() {
    return "from ${startDate.toString().substring(0, 10)} to ${endDate.toString().substring(0, 10)}";
  }
}

extension WeekUtils on DateTime {
  DateTime startOfWeek() => normalized().subtract(Duration(days: weekday - 1));

  DateTime endOfWeek() => normalized().add(Duration(days: 7 - weekday));
}
