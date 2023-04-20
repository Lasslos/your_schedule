import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/holiday.dart';
import 'package:your_schedule/untis/models/user_data/internal_general_data.dart';
import 'package:your_schedule/untis/models/user_data/internal_user_data.dart';
import 'package:your_schedule/untis/models/user_data/klasse.dart';
import 'package:your_schedule/untis/models/user_data/room.dart';
import 'package:your_schedule/untis/models/user_data/subject.dart';
import 'package:your_schedule/untis/models/user_data/teacher.dart';
import 'package:your_schedule/untis/models/user_data/time_grid.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

@freezed
class UserData with _$UserData {
  const factory UserData(
    @protected InternalGeneralData generalData,
    @protected InternalUserData userData,
  ) = _UserData;

  const UserData._();

  List<Holiday> get holidays => generalData.holidays;

  List<Klasse> get klassen => generalData.klassen;

  List<Room> get rooms => generalData.rooms;

  List<Subject> get subjects => generalData.subjects;

  List<Teacher> get teachers => generalData.teachers;

  TimeGrid get timeGrid => generalData.timeGrid;

  String get displayName => userData.displayName;

  String get schoolName => userData.schoolName;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
