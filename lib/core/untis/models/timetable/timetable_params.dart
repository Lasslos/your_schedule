import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_params.freezed.dart';
part 'timetable_params.g.dart';

@freezed
abstract class TimeTableParams with _$TimeTableParams {
  const factory TimeTableParams(
    int id,
    String type,
    DateTime startDate,
    DateTime endDate,
  ) = _TimeTableParams;

  factory TimeTableParams.fromJson(Map<String, dynamic> json) =>
      _$TimeTableParamsFromJson(json);
}
