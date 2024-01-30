import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/utils.dart';

part 'time_grid_entry.freezed.dart';
part 'time_grid_entry.g.dart';

@freezed
class TimeGridEntry with _$TimeGridEntry {
  const factory TimeGridEntry(
    String label,
    @TimeOfDaySerializer() TimeOfDay startTime,
    @TimeOfDaySerializer() TimeOfDay endTime,
  ) = _TimeGridEntry;

  const TimeGridEntry._();

  factory TimeGridEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeGridEntryFromJson(json);

  Duration get length => Duration(
        minutes: (endTime.hour * 60 + endTime.minute) -
            (startTime.hour * 60 + startTime.minute),
      );
}
