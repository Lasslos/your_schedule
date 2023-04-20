import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/holiday.dart';
import 'package:your_schedule/untis/models/user_data/klasse.dart';
import 'package:your_schedule/untis/models/user_data/room.dart';
import 'package:your_schedule/untis/models/user_data/subject.dart';
import 'package:your_schedule/untis/models/user_data/teacher.dart';
import 'package:your_schedule/untis/models/user_data/time_grid.dart';

part 'internal_general_data.freezed.dart';
part 'internal_general_data.g.dart';

@freezed
class InternalGeneralData with _$InternalGeneralData {
  @JsonSerializable(explicitToJson: true)
  const factory InternalGeneralData(List<Holiday> holidays,
      List<Klasse> klassen,
      List<Room> rooms,
      List<Subject> subjects,
      List<Teacher> teachers,
      TimeGrid timeGrid,) = _InternalGeneralData;

  factory InternalGeneralData.fromJson(Map<String, dynamic> json) =>
      _$InternalGeneralDataFromJson(json);
}
