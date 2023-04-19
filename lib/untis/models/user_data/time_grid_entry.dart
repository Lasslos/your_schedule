import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/util/time_of_day_serializer.dart';

part 'time_grid_entry.freezed.dart';
part 'time_grid_entry.g.dart';

@freezed
class TimeGridEntry with _$TimeGridEntry {
  factory TimeGridEntry({
    required String label,
    @TimeOfDaySerializer() required TimeOfDay startTime,
    @TimeOfDaySerializer() required TimeOfDay endTime,
  }) = _TimeGridEntry;

  factory TimeGridEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeGridEntryFromJson(json);
}
