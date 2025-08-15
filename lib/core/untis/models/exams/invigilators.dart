import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/utils.dart';

part 'invigilators.freezed.dart';
part 'invigilators.g.dart';

@freezed
abstract class Invigilators with _$Invigilators {
  const factory Invigilators(
    int id,
    @TimeOfDaySerializer() TimeOfDay startTime,
    @TimeOfDaySerializer() TimeOfDay endTime,
  ) = _Invigilators;

  factory Invigilators.fromJson(Map<String, dynamic> json) =>
      _$InvigilatorsFromJson(json);
}
