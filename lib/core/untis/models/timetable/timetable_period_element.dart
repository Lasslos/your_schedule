import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_period_element.freezed.dart';
part 'timetable_period_element.g.dart';

@Freezed(unionKey: 'type')
sealed class TimeTablePeriodElement with _$TimeTablePeriodElement {
  @JsonSerializable(explicitToJson: true)
  @FreezedUnionValue('CLASS')
  const factory TimeTablePeriodElement.clazz(
    int id,
    int orgId,
  ) = ClazzId;

  @FreezedUnionValue('TEACHER')
  const factory TimeTablePeriodElement.teacher(
    int id,
    int orgId,
  ) = TeacherId;

  @FreezedUnionValue('SUBJECT')
  const factory TimeTablePeriodElement.subject(
    int id,
    int orgId,
  ) = SubjectId;

  @FreezedUnionValue('ROOM')
  const factory TimeTablePeriodElement.room(
    int id,
    int orgId,
  ) = RoomId;

  factory TimeTablePeriodElement.fromJson(Map<String, dynamic> json) =>
      _$TimeTablePeriodElementFromJson(json);
}
