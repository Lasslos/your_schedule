import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/weekday.dart';

@immutable
class TimeTableDay {
  final DateTime date;
  //Die Liste der Stunden, sortiert nach Startzeit
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

  ///Der Tag in der Woche, beginnend mit 1
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
