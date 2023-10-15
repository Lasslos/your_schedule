import 'package:flutter/foundation.dart';
import 'package:your_schedule/util/date_utils.dart';

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

//Note: Week starts on Saturday to show next week after Friday
extension WeekUtils on DateTime {
  DateTime startOfWeek() => normalized().subtract(Duration(days: (weekday - 6) % 7));

  DateTime endOfWeek() => normalized().add(Duration(days: (5 - weekday) % 7));
}
