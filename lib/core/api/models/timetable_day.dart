import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/weekday.dart';

@immutable
class TimeTableDay {
  final DateTime date;

  /// How many hours minimum should be displayed per day, if there are no lessons
  static const int minHoursPerDay = 8;

  ///Maps the start time to a TimeTablePeriod
  final Map<DateTime, List<TimeTablePeriod>> periods;

  TimeTableDay withPeriod(TimeTablePeriod period) {
    return copyWith(
        periods: {...periods}..putIfAbsent(period.start, () => []).add(period));
  }

  final Weekday weekday;
  final String formattedDay;
  final String formattedMonth;

  String get formattedDate => "$formattedDay.$formattedMonth";

  final bool isHolidayOrWeekend;

  ///What day in the week it is. Monday is 0, Tuesday is 1, etc.
  final int dayNumber;

  TimeTableDay(this.date, this.dayNumber,
      {this.isHolidayOrWeekend = false,
      Map<DateTime, List<TimeTablePeriod>> periods = const {}})
      : weekday = Weekday.values[date.weekday - 1],
        formattedDay = date.convertToUntisDate().substring(6),
        formattedMonth = date.convertToUntisDate().substring(4, 6),
        periods = Map.unmodifiable(periods);

  TimeTableDay copyWith({
    DateTime? date,
    int? dayNumber,
    bool? isHolidayOrWeekend,
    Map<DateTime, List<TimeTablePeriod>>? periods,
  }) {
    return TimeTableDay(
      date ?? this.date,
      dayNumber ?? this.dayNumber,
      isHolidayOrWeekend: isHolidayOrWeekend ?? this.isHolidayOrWeekend,
      periods: periods ?? this.periods,
    );
  }
}
