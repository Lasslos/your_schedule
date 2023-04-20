import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_period.freezed.dart';
part 'timetable_period.g.dart';

@freezed
class TimeTablePeriod with _$TimeTablePeriod {
  @JsonSerializable(explicitToJson: true)
  const factory TimeTablePeriod(
    int id,
    int lessonId,
    @JsonKey(name: "startDateTime") DateTime startTime,
    @JsonKey(name: "endDateTime") DateTime endTime,
    @protected @JsonKey(name: "text") String internalPeriodText,
  ) = _TimeTablePeriod;

  factory TimeTablePeriod.fromJson(Map<String, dynamic> json) =>
      _$TimeTablePeriodFromJson(json);
}
