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
  final List<TimeTablePeriod> periods;

  TimeTableDay withPeriod(TimeTablePeriod period) {
    return copyWith(
      periods: [...periods, period],
    );
  }

  final Weekday weekday;
  final String formattedDay;
  final String formattedMonth;

  String get formattedDate => "$formattedDay.$formattedMonth";

  final bool isHolidayOrWeekend;

  ///What day in the week it is. Monday is 0, Tuesday is 1, etc.
  final int dayNumber;

  TimeTableDay(
    this.date,
    this.dayNumber, {
    this.isHolidayOrWeekend = false,
    List<TimeTablePeriod> periods = const [],
  })  : weekday = Weekday.values[date.weekday - 1],
        formattedDay = date.convertToUntisDate().substring(6),
        formattedMonth = date.convertToUntisDate().substring(4, 6),
        periods = List.unmodifiable(
          [...periods]..sort((a, b) => a.start.compareTo(b.start)),
        );

  TimeTableDay copyWith({
    DateTime? date,
    int? dayNumber,
    bool? isHolidayOrWeekend,
    List<TimeTablePeriod>? periods,
  }) {
    return TimeTableDay(
      date ?? this.date,
      dayNumber ?? this.dayNumber,
      isHolidayOrWeekend: isHolidayOrWeekend ?? this.isHolidayOrWeekend,
      periods: periods ?? this.periods,
    );
  }
}
