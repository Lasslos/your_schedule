import 'package:your_schedule/core/api/models/timetable_period.dart';
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

  int daysSinceEpoch;
  bool isHolidayOrWeekend = false;

  ///What day in the week it is. Monday is 0, Tuesday is 1, etc.
  final int dayNumber;

  final TimeTableRange range;

  TimeTableDay(this.date, this.range)
      : weekday = Weekday.values[date.weekday - 1],
        formattedDay = convertToUntisDate(date).substring(6),
        formattedMonth = convertToUntisDate(date).substring(4, 6) {
    //TODO: Understand this
    for (int i = 0; i < minHoursPerDay; i++) {
      TimeTablePeriod? t = TimeTablePeriod(null, range);
      t.startAsString = _rng
          .getBoundFrame()
          .getManager()
          .timegrid
          .getEntryByYIndex(yIndex: i)
          .startTime;
      hours.add(TimeTablePeriod(null, range)); //Leere Stunden
    }
  }

  void insertPeriod(TimeTablePeriod period) {
    //TODO: Understand this
  }
}
