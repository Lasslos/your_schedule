import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/time_grid_entry.dart';

part 'time_grid.freezed.dart';
part 'time_grid.g.dart';

@freezed
class TimeGrid with _$TimeGrid {
  @JsonSerializable(explicitToJson: true)
  const factory TimeGrid(
    @_TimeGridConverter() List<TimeGridEntry> timeGridEntries,
  ) = _TimeGrid;

  factory TimeGrid.fromJson(Map<String, dynamic> json) =>
      _$TimeGridFromJson(json);
}

class _TimeGridConverter
    implements JsonConverter<TimeGrid, Map<String, dynamic>> {
  const _TimeGridConverter();

  @override
  TimeGrid fromJson(Map<String, dynamic> json) {
    return TimeGrid.fromJson(json['days'][0]["untis"]);
  }

  @override
  Map<String, dynamic> toJson(TimeGrid object) {
    return {
      'days': [
        {'untis': object.toJson()},
      ],
    };
  }
}
