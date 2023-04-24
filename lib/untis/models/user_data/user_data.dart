import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/untis/models/user_data/holiday.dart';
import 'package:your_schedule/untis/models/user_data/klasse.dart';
import 'package:your_schedule/untis/models/user_data/room.dart';
import 'package:your_schedule/untis/models/user_data/subject.dart';
import 'package:your_schedule/untis/models/user_data/teacher.dart';
import 'package:your_schedule/untis/models/user_data/time_grid.dart';

part 'user_data.freezed.dart';

@Freezed(fromJson: false, toJson: false)
class UserData with _$UserData {
  const factory UserData(
    int timeStamp,
    Map<int, Holiday> holidays,
    Map<int, Klasse> klassen,
    Map<int, Room> rooms,
    Map<int, Subject> subjects,
    Map<int, Teacher> teachers,
    TimeGrid timeGrid,
    String type,
    int id,
    String displayName,
    String schoolName,
  ) = _UserData;

  const UserData._();

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      json['masterData']['timeStamp'] as int,
      {
        for (var e in json['masterData']['holidays'])
          e['id'] as int: Holiday.fromJson(e)
      },
      {
        for (var e in json['masterData']['klassen'])
          e['id'] as int: Klasse.fromJson(e)
      },
      {
        for (var e in json['masterData']['rooms'])
          e['id'] as int: Room.fromJson(e)
      },
      {
        for (var e in json['masterData']['subjects'])
          e['id'] as int: Subject.fromJson(e)
      },
      {
        for (var e in json['masterData']['teachers'])
          e['id'] as int: Teacher.fromJson(e)
      },
      TimeGrid.fromJson(
          (json['masterData']['timegrid']['days'] as List<dynamic>)
              .first()['untis']),
      json['userData']['elemType'] as String,
      json['userData']['elemId'] as int,
      json['userData']['displayName'] as String,
      json['userData']['schoolName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'masterData': {
        'timeStamp': timeStamp,
        'holidays': holidays.entries
            .map((e) => {'id': e.key, ...e.value.toJson()})
            .toList(),
        'klassen': klassen.entries
            .map((e) => {'id': e.key, ...e.value.toJson()})
            .toList(),
        'rooms': rooms.entries
            .map((e) => {'id': e.key, ...e.value.toJson()})
            .toList(),
        'subjects': subjects.entries
            .map((e) => {'id': e.key, ...e.value.toJson()})
            .toList(),
        'teachers': teachers.entries
            .map((e) => {'id': e.key, ...e.value.toJson()})
            .toList(),
        'timegrid': {
          'days': [
            {
              'untis': timeGrid.toJson(),
            }
          ],
        },
      },
      'userData': {
        'elemType': type,
        'elemId': id,
        'displayName': displayName,
        'schoolName': schoolName,
      },
    };
  }
}
