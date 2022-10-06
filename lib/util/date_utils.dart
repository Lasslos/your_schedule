import 'package:flutter/material.dart';

extension DateUtils on DateTime {
  String convertToUntisDate() {
    return (year >= 1000 ? year.toString() : "1970") +
        (month < 10 ? '0$month' : month.toString()) +
        (day < 10 ? '0$day' : day.toString()).toString();
  }

  int daysSinceEpoch() => difference(DateTime(1970)).inDays;

  bool dayIsInBetweenTwoOtherDays(DateTime before, DateTime after) =>
      daysSinceEpoch() > before.daysSinceEpoch() &&
      daysSinceEpoch() < after.daysSinceEpoch();

  bool isInBetweenTwoOther(DateTime before, DateTime after) =>
      difference(before).inMilliseconds > 0 &&
      difference(after).inMilliseconds < 0;

  bool isSameDay(DateTime other) => daysSinceEpoch() == other.daysSinceEpoch();

  bool isGreaterOrEqual(DateTime other) =>
      daysSinceEpoch() >= other.daysSinceEpoch();

  DateTime normalized() => DateTime(year, month, day);

  String toDDMMYY() =>
      "${day.toString().padLeft(2, "0")}${month.toString().padLeft(2, "0")}${year.toString().substring(2, 4)}";

  String toDDMM() =>
      "${day.toString().padLeft(2, "0")}.${month.toString().padLeft(2, "0")}";
}

extension DateUtilsOnString on String {
  DateTime convertUntisDateToDateTime() => DateTime.parse(this);
}

extension TimeOfDayUtils on TimeOfDay {
  Duration difference(TimeOfDay other) {
    return Duration(
      seconds: differenceToMidnight().inSeconds - other.differenceToMidnight().inSeconds,
    );
  }

  Duration differenceToMidnight() {
    return Duration(
      hours: hour,
      minutes: minute,
    );
  }

  String toMyString() => "$hour:$minute";
}