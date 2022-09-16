import 'package:your_schedule/util/weekday.dart';

class TimeTableDay {
  final DateTime date;

  /// How many hours minimum should be displayed per day, if there are no lessons
  static const int minHoursPerDay = 5;

  final hours = <TimeTableHour>[];
  final Weekday weekday;
  final String formattedDay;
  final String formattedMonth;

  int daysSinceEpoch;
  bool outOfScope = false;

  //TODO: Rename as soon as you know what this means
  int xIndex = -1;

  final TimeTableRange range;

  TimeTableDay(this.date, this.range)
      : weekday = Weekday.values[date.weekday - 1],
        formattedDay = DateFormat('dd').format(date),
        formattedMonth = DateFormat('MMM').format(date);

//TODO (Lasslos): Implement as soon as other important models (timetable.hour, timetable.entity) are done.
}
