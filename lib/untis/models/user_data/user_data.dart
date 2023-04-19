import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/holiday.dart';
import 'package:your_schedule/untis/models/user_data/klasse.dart';
import 'package:your_schedule/untis/models/user_data/room.dart';
import 'package:your_schedule/untis/models/user_data/subject.dart';
import 'package:your_schedule/untis/models/user_data/teacher.dart';
import 'package:your_schedule/untis/models/user_data/time_grid.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

@freezed
class UserData with _$UserData {
  factory UserData({
    @JsonKey(readValue: _readMasterData) required List<Holiday> holidays,
    @JsonKey(readValue: _readMasterData) required List<Klasse> klassen,
    @JsonKey(readValue: _readMasterData) required List<Room> rooms,
    @JsonKey(readValue: _readMasterData) required List<Subject> subjects,
    @JsonKey(readValue: _readMasterData) required List<Teacher> teachers,
    @JsonKey(readValue: _readMasterData) required TimeGrid timeGrid,
    @JsonKey(readValue: _readUserData) required String displayName,
    @JsonKey(readValue: _readUserData) required String schoolName,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}

dynamic _readMasterData(Map<dynamic, dynamic> json, String name) {
  return json['masterData'][name];
}

dynamic _readUserData(Map<dynamic, dynamic> json, String name) {
  return json['userData'][name];
}
