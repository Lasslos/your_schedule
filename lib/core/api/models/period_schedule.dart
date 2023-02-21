import 'package:flutter/material.dart';
import 'package:your_schedule/util/date_utils.dart';

///Eintrag in [PeriodSchedule], der einen Zeitraum repräsentiert, in dem eine Schulstunde stattfindet.
@immutable
class PeriodScheduleEntry {
  ///Die Nummer der Schulstunde, beginnend bei 1.
  final int periodNumber;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const PeriodScheduleEntry._(this.periodNumber, this.startTime, this.endTime);

  ///Konstruiert einen [PeriodScheduleEntry] aus einer [Map] mit den Schlüsseln `unitOfDay`, `startTime` und `endTime`.
  ///Dies ist unsicher, wenn die Map diese Schlüssel nicht enthält.
  factory PeriodScheduleEntry.fromJson(Map<String, dynamic> json) {
    assert(json.isNotEmpty, "json must not be empty");
    assert(json['errorMessage'] == null, json['errorMessage']);
    int periodNumber = json['unitOfDay'];
    String startTimeString =
        (json['startTime'] ?? "0000").toString().padLeft(4, '0');
    String endTimeString =
        (json['endTime'] ?? "0000").toString().padLeft(4, '0');
    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(startTimeString.substring(0, 2)),
      minute: int.parse(startTimeString.substring(2, 4)),
    );
    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(endTimeString.substring(0, 2)),
      minute: int.parse(endTimeString.substring(2, 4)),
    );
    return PeriodScheduleEntry._(periodNumber, startTime, endTime);
  }

  Duration get length => endTime.difference(startTime);
}

///Ein [PeriodSchedule] ist eine Liste von [PeriodScheduleEntry]s. Dies stellt den Stundenplan eines Tages dar.
@immutable
class PeriodSchedule {
  final int schoolYearId;
  final List<PeriodScheduleEntry> entries;

  final PeriodScheduleEntry fallback = const PeriodScheduleEntry._(
    -1,
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 0, minute: 0),
  );

  const PeriodSchedule._(this.schoolYearId, this.entries);

  ///Konstruiert einen [PeriodSchedule] aus einer [Map] mit den Schlüsseln `schoolyearId` und `units`.
  ///Dies ist unsicher, wenn die Map diese Schlüssel nicht enthält.
  PeriodSchedule.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        schoolYearId = json['schoolyearId'],
        entries = List.unmodifiable(
          (json['units'] as List<dynamic>)
              .map((e) => PeriodScheduleEntry.fromJson(e))
              .toList()
            ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber)),
        );

  PeriodScheduleEntry operator [](int periodNumber) {
    return entries[periodNumber];
  }

  //Daten, falls der Stundenplan nicht geladen werden konnte
  static const PeriodSchedule periodScheduleFallback = PeriodSchedule._(
    -1,
    [
      PeriodScheduleEntry._(
        1,
        TimeOfDay(hour: 7, minute: 55),
        TimeOfDay(hour: 8, minute: 55),
      ),
      PeriodScheduleEntry._(
        2,
        TimeOfDay(hour: 9, minute: 10),
        TimeOfDay(hour: 10, minute: 10),
      ),
      PeriodScheduleEntry._(
        3,
        TimeOfDay(hour: 10, minute: 20),
        TimeOfDay(hour: 11, minute: 20),
      ),
      PeriodScheduleEntry._(
        4,
        TimeOfDay(hour: 11, minute: 45),
        TimeOfDay(hour: 12, minute: 45),
      ),
      PeriodScheduleEntry._(
        5,
        TimeOfDay(hour: 12, minute: 55),
        TimeOfDay(hour: 13, minute: 55),
      ),
      PeriodScheduleEntry._(
        6,
        TimeOfDay(hour: 13, minute: 55),
        TimeOfDay(hour: 14, minute: 25),
      ),
      PeriodScheduleEntry._(
        7,
        TimeOfDay(hour: 14, minute: 25),
        TimeOfDay(hour: 15, minute: 25),
      ),
      PeriodScheduleEntry._(
        8,
        TimeOfDay(hour: 15, minute: 35),
        TimeOfDay(hour: 16, minute: 35),
      ),
    ],
  );
}
