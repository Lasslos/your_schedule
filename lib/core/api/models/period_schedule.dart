///Entry in [PeriodSchedule] representing one period of time, in which a lesson (could) take place.
class PeriodScheduleEntry {
  ///What period of the day it is. First period is 0.
  final int periodNumber;
  final String startTime;
  final String endTime;

  PeriodScheduleEntry._(this.periodNumber, this.startTime, this.endTime);

  ///Constructs a [PeriodScheduleEntry] from a [Map] with the keys `unitOfDay`, `startTime` and `endTime`.
  ///This is unsafe if the map does not contain these keys.
  PeriodScheduleEntry.fromJson(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        periodNumber = json['unitOfDay'] - 1,
        startTime = (json['startTime'] ?? "0000").toString(),
        endTime = (json['endTime'] ?? "0000").toString();
}

///A [PeriodSchedule] is a list of [PeriodScheduleEntry]s. This represents the schedule of a day.
class PeriodSchedule {
  final int schoolYearId;
  final List<PeriodScheduleEntry> entries;

  final PeriodScheduleEntry fallback =
      PeriodScheduleEntry._(-1, "0000", "0000");

  PeriodSchedule._(this.schoolYearId, this.entries);

  ///Constructs a [PeriodSchedule] from a [Map] with the keys `schoolyearId` and `units`.
  ///This is unsafe if the map does not contain these keys.
  PeriodSchedule.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        schoolYearId = json['schoolyearId'],
        entries = (json['units'] as List<dynamic>)
            .map((e) => PeriodScheduleEntry.fromJson(e))
            .toList()
          ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

  PeriodScheduleEntry operator [](int periodNumber) {
    for (PeriodScheduleEntry entry in entries) {
      if (entry.periodNumber == periodNumber) {
        return entry;
      }
    }
    return fallback;
  }

  //Fallback to default values.
  static PeriodSchedule periodScheduleFallback = PeriodSchedule._(
    -1,
    [
      PeriodScheduleEntry._(0, "755", "855"),
      PeriodScheduleEntry._(1, "910", "1010"),
      PeriodScheduleEntry._(2, "1020", "1120"),
      PeriodScheduleEntry._(3, "1145", "1245"),
      PeriodScheduleEntry._(4, "1255", "1355"),
      PeriodScheduleEntry._(5, "1355", "1425"),
      PeriodScheduleEntry._(6, "1425", "1525"),
      PeriodScheduleEntry._(7, "1535", "1635"),
    ],
  );
}
