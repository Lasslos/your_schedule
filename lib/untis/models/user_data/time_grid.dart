import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/time_grid_entry.dart';

part 'time_grid.freezed.dart';
part 'time_grid.g.dart';

@freezed
class TimeGrid with _$TimeGrid {
  const factory TimeGrid({
    @JsonKey(readValue: _readTimeGridEntries)
        required List<TimeGridEntry> timeGridEntries,
  }) = _TimeGrid;

  factory TimeGrid.fromJson(Map<String, dynamic> json) =>
      _$TimeGridFromJson(json);
}

dynamic _readTimeGridEntries(Map<dynamic, dynamic> json, String name) {
  return json['days'][0]["untis"];
}
