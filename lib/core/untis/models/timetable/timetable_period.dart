import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/untis/models/timetable/internal_period_text.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_exam_information.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period_element.dart';
import 'package:your_schedule/core/untis/models/timetable/timetable_period_status.dart';

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
    @protected @JsonKey(name: "text") InternalPeriodText internalPeriodText,
    @protected List<TimeTablePeriodElement> elements,
    @JsonKey(name: "is") List<TimeTablePeriodStatus> periodStatus,
    TimeTableExamInformation? examInformation,
  ) = _TimeTablePeriod;

  const TimeTablePeriod._();

  String get lessonText => internalPeriodText.lesson;

  String get substitutionText => internalPeriodText.substitution;

  String get infoText => internalPeriodText.info;

  Clazz get clazz =>
      elements.firstWhere((element) => element is Clazz) as Clazz;

  Teacher get teacher =>
      elements.firstWhere((element) => element is Teacher) as Teacher;

  Subject get subject =>
      elements.firstWhere((element) => element is Subject) as Subject;

  Room get room => elements.firstWhere((element) => element is Room) as Room;

  factory TimeTablePeriod.fromJson(Map<String, dynamic> json) =>
      _$TimeTablePeriodFromJson(json);
}
