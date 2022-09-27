import 'package:flutter/material.dart';
import 'package:your_schedule/core/api/models/timetable_period_information_elements.dart';

///Stores information about the status of a period.
enum PeriodStatus {
  regular("Regulär"),
  irregular("Vertretung"),
  cancelled("Entfall"),
  empty("Unbekannt"),
  unknown("Unbekannt");

  const PeriodStatus(this.readableName);

  factory PeriodStatus.fromCode(String? code) {
    switch (code) {
      case "regular":
        return regular;
      case "irregular":
        return irregular;
      case "cancelled":
        return cancelled;
      case null:
        return regular;
      default:
        return unknown;
    }
  }

  final String readableName;
}

@immutable
class TimeTablePeriod {
  final TimeTablePeriodSchoolClassInformation schoolClass;
  final TimeTablePeriodTeacherInformation teacher;
  final TimeTablePeriodSubjectInformation subject;
  final TimeTablePeriodRoomInformation room;

  ///If the status of this period is irregular, this will contain the replacement for the lesson.
  bool get isIrregular => periodStatus == PeriodStatus.irregular;

  ///Information that the teacher might have added to the period. Important if the period is irregular.
  final String? substText;
  final String? activityType;
  final int id;

  final DateTime start;

  String get startAsString =>
      start.hour.toString().padLeft(2, "0") +
      start.minute.toString().padLeft(2, "0");
  final DateTime end;

  String get endAsString =>
      end.hour.toString().padLeft(2, "0") +
      end.minute.toString().padLeft(2, "0");

  final PeriodStatus periodStatus;

  const TimeTablePeriod._(
    this.schoolClass,
    this.teacher,
    this.subject,
    this.room,
    this.substText,
    this.activityType,
    this.id,
    this.start,
    this.end,
    this.periodStatus,
  );

  factory TimeTablePeriod.fromJSON(Map<String, dynamic> json) {
    assert(json.isNotEmpty, "json must not be empty.");
    int id = json["id"];
    String startAsString = json["startTime"].toString();
    String endAsString = json["endTime"].toString();
    String date = json["date"].toString();
    DateTime start = _parseDate(date, startAsString);
    DateTime end = _parseDate(date, endAsString);
    String? activityType = json["activityType"];
    String? substText = json["substText"];
    TimeTablePeriodSchoolClassInformation schoolClass =
        json["kl"] != null && json["kl"].isNotEmpty
            ? TimeTablePeriodSchoolClassInformation.fromJSON(json["kl"][0])
            : const TimeTablePeriodSchoolClassInformation(
                "unknown", "unknown", null);

    TimeTablePeriodTeacherInformation teacher = json["te"] != null &&
            json["te"].isNotEmpty
        ? TimeTablePeriodTeacherInformation.fromJSON(json["te"][0])
        : const TimeTablePeriodTeacherInformation("---", "Kein Lehrer", null);

    TimeTablePeriodSubjectInformation subject = json["su"].isNotEmpty
        ? TimeTablePeriodSubjectInformation.fromJSON(json["su"][0])
        : const TimeTablePeriodSubjectInformation("---", "Kein Fach", null);
    TimeTablePeriodRoomInformation room = json["ro"].isNotEmpty
        ? TimeTablePeriodRoomInformation.fromJSON(json["ro"][0])
        : const TimeTablePeriodRoomInformation("---", "Kein Raum", null);
    PeriodStatus status = PeriodStatus.fromCode(json["code"]);

    return TimeTablePeriod._(
      schoolClass,
      teacher,
      subject,
      room,
      substText,
      activityType,
      id,
      start,
      end,
      status,
    );
  }

  String getStartEndTimeAsString() {
    return "$startAsString - $endAsString";
  }

  @override
  String toString() {
    return "${subject.name} (${teacher.name}) Code: ${periodStatus.name}";
  }
}

DateTime _parseDate(String date, String time) {
  int year = int.parse(date.substring(0, 4));
  int month = int.parse(date.substring(4, 6));
  int day = int.parse(date.substring(6, 8));
  int hour = int.parse(time.padLeft(4, "0").substring(0, 2));
  int minute = int.parse(time.padLeft(4, "0").substring(2, 4));
  return DateTime(year, month, day, hour, minute);
}
