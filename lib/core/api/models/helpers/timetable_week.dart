import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_day.dart';
import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/rpc_response.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/logger.dart';

@immutable
class TimeTableWeek {
  final Week week;
  final Map<DateTime, TimeTableDay> days;

  bool get isEmpty => days.isEmpty;

  TimeTableWeek(this.week, Map<DateTime, TimeTableDay> days)
      : days = Map.unmodifiable(days);

  factory TimeTableWeek.fromRPCResponse(Week week, RPCResponse response) {
    final Map<DateTime, TimeTableDay> days = {};

    if (response.isError) {
      if (response.errorCode == -7004) {
        //"no allowed date" - Das bedeutet, dass der Stundenplan noch nicht verfügbar ist
        //Wir füllen die Woche mit leeren Tagen
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

    ///Gehe durch alle Einträge und füge sie den Tagen hinzu
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
      getLogger().w(
        "Error while loading timetable. Response JSON might be malformed.",
      );
      rethrow;
    }

    ///Füge leere Tage hinzu, falls es keine Einträge für einen Tag gibt
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

  ///Erstellt ein Wochenobjekt, das die Woche enthält, in der das übergebene Datum liegt
  Week.fromDateTime(DateTime momentInWeek)
      : startDate = momentInWeek.startOfWeek(),
        endDate = momentInWeek.endOfWeek();

  Week.now() : this.fromDateTime(DateTime.now());

  Week.relative(int relative)
      : startDate =
            DateTime.now().startOfWeek().add(Duration(days: relative * 7)),
        endDate = DateTime.now().endOfWeek().add(Duration(days: relative * 7));

  List<DateTime> get daysInWeek =>
      [for (int i = 0; i < 7; i++) startDate.add(Duration(days: i))];

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
    return "${startDate.toString().substring(0, 10)} bis ${endDate.toString().substring(0, 10)}";
  }
}

extension WeekUtils on DateTime {
  DateTime startOfWeek() => normalized().subtract(Duration(days: weekday - 1));

  DateTime endOfWeek() => normalized().add(Duration(days: 7 - weekday));
}
