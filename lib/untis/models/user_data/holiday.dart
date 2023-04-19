import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday.freezed.dart';
part 'holiday.g.dart';

@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required int id,
    required String name,
    required String longName,
    required DateTime startDate,
    required DateTime endDate,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
