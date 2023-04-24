import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_exam_information.freezed.dart';
part 'timetable_exam_information.g.dart';

@freezed
class TimeTableExamInformation with _$TimeTableExamInformation {
  const factory TimeTableExamInformation(
    int id,
    String? examType,
    String name,
    String text,
  ) = _TimeTableExamInformation;

  factory TimeTableExamInformation.fromJson(Map<String, dynamic> json) =>
      _$TimeTableExamInformationFromJson(json);
}
