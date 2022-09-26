import 'package:flutter/material.dart';

///Stores information about the class (Grade, Tutor group, School Class), the user is in.
@immutable
class SchoolClass {
  final int type;

  final int id;
  final String name;
  final String displayName;
  final String? classTeacherName;
  final String? classTeacherLongName;
  final String? classTeacher2Name;
  final String? classTeacher2LongName;

  ///Constructs a [SchoolClass] from a [Map] with the keys `type`, `id`, `name`, `displayName`, `classTeacher-Name`, `classTeacher-LongName`, `classTeacher2-Name` and `classTeacher2-LongName` (lowercase).
  ///This is unsafe if the map does not contain these keys.
  SchoolClass.fromJson(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        type = json['type'],
        id = json['id'],
        name = json['name'],
        displayName = json['displayname'],
        classTeacherName = json['classteacher']['name'],
        classTeacherLongName = json['classteacher']['longName'],
        classTeacher2Name = json['classteacher2']['name'],
        classTeacher2LongName = json['classteacher2']['longName'];
}
