import 'package:your_schedule/core/api/models/timetable_period.dart';
import 'package:your_schedule/core/api/timetable_time_span.dart';
import 'package:your_schedule/util/date_utils.dart';
import 'package:your_schedule/util/weekday.dart';

class TimeTableDay {
  final DateTime date;

  /// How many hours minimum should be displayed per day, if there are no lessons
  static const int minHoursPerDay = 8;

  final List<TimeTablePeriod?> hours = [];
  final Weekday weekday;
  final String formattedDay;
  final String formattedMonth;

  String get formattedDate => "$formattedDay.$formattedMonth";

  bool isHolidayOrWeekend = false;

  ///What day in the week it is. Monday is 0, Tuesday is 1, etc.
  final int dayNumber;

  final TimeTableTimeSpan timeSpan;

  TimeTableDay(this.date, this.timeSpan, this.dayNumber)
      : weekday = Weekday.values[date.weekday - 1],
        formattedDay = date.convertToUntisDate().substring(6),
        formattedMonth = date.convertToUntisDate().substring(4, 6) {
    //TODO: Understand this
    for (int i = 0; i < minHoursPerDay; i++) {
      TimeTablePeriod? period = TimeTablePeriod(null, timeSpan);
      period.startAsString = timeSpan
          .getBoundFrame()
          .getManager()
          .timegrid
          .getEntryByYIndex(yIndex: i)
          .startTime;
      hours.add(TimeTablePeriod(null, range)); //Leere Stunden
    }
  }

  void insertPeriod(TimeTablePeriod Function(TimeTableTimeSpan) createPeriod) {
    //TODO: Understand this
  }
}
