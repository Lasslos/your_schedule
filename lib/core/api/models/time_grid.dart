class TimeGridEntry {
  //TODO: Rename as soon as you know what this means
  final int yIndex;
  final String startTime;
  final String endTime;

  TimeGridEntry._(this.yIndex, this.startTime, this.endTime);

  ///Constructs a [TimeGridEntry] from a [Map] with the keys `unitOfDay`, `startTime` and `endTime`.
  ///This is unsafe if the map does not contain these keys.
  TimeGridEntry.fromJson(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        yIndex = json['unitOfDay'] - 1,
        startTime = (json['startTime'] ?? "0000").toString(),
        endTime = (json['endTime'] ?? "0000").toString();
}

class TimeGrid {
  final int schoolYearId;
  final List<TimeGridEntry> entries;

  final TimeGridEntry fallback = TimeGridEntry._(-1, "0000", "0000");

  TimeGrid._(this.schoolYearId, this.entries);

  ///Constructs a [TimeGrid] from a [Map] with the keys `schoolyearId` and `units`.
  ///This is unsafe if the map does not contain these keys.
  TimeGrid.fromJson(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        schoolYearId = json['schoolyearId'],
        entries = (json['units'] as List<dynamic>)
            .map((e) => TimeGridEntry.fromJson(e))
            .toList()
          ..sort((a, b) => a.yIndex.compareTo(b.yIndex));

  TimeGridEntry operator [](int yIndex) {
    for (TimeGridEntry entry in entries) {
      if (entry.yIndex == yIndex) {
        return entry;
      }
    }
    return fallback;
  }

  //Fallback to default values.
  static TimeGrid timeGridFallback = TimeGrid._(
    -1,
    [
      TimeGridEntry._(0, "800", "845"),
      TimeGridEntry._(1, "850", "935"),
      TimeGridEntry._(2, "940", "1025"),
      TimeGridEntry._(3, "1030", "1115"),
      TimeGridEntry._(4, "1120", "1205"),
      TimeGridEntry._(5, "1210", "1255"),
      TimeGridEntry._(6, "1300", "1345"),
      TimeGridEntry._(7, "1350", "1435"),
      TimeGridEntry._(8, "1440", "1525"),
      TimeGridEntry._(9, "1530", "1615"),
      TimeGridEntry._(10, "1620", "1705"),
      TimeGridEntry._(11, "1710", "1755"),
      TimeGridEntry._(12, "1800", "1845"),
      TimeGridEntry._(13, "1850", "1935"),
      TimeGridEntry._(14, "1940", "2025"),
      TimeGridEntry._(15, "2030", "2115"),
      TimeGridEntry._(16, "2120", "2205"),
      TimeGridEntry._(17, "2210", "2255"),
      TimeGridEntry._(18, "2300", "2345"),
    ],
  );
}
