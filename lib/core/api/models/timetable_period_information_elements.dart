import 'package:flutter/material.dart';

///Information about the period's school class.
@immutable
class TimeTablePeriodSchoolClassInformation {
  final String name;
  final String longName;
  final int? identifier;

  const TimeTablePeriodSchoolClassInformation(
    this.name,
    this.longName,
    this.identifier,
  );

  TimeTablePeriodSchoolClassInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longname'],
        identifier = json['id'];

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "longname": longName,
      "id": identifier,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeTablePeriodSchoolClassInformation &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          longName == other.longName &&
          identifier == other.identifier;

  @override
  int get hashCode => Object.hash(name, longName, identifier);
}

///Information about the period's teacher.
@immutable
class TimeTablePeriodTeacherInformation {
  final String name;
  final String longName;
  final int? identifier;

  const TimeTablePeriodTeacherInformation(
    this.name,
    this.longName,
    this.identifier,
  );

  TimeTablePeriodTeacherInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longname'],
        identifier = json['id'];

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "longname": longName,
      "id": identifier,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimeTablePeriodTeacherInformation &&
          runtimeType == other.runtimeType &&
              name == other.name &&
              longName == other.longName &&
              identifier == other.identifier;

  @override
  int get hashCode => Object.hash(name, longName, identifier);
}

///Information about the period's subject.
@immutable
class TimeTablePeriodSubjectInformation {
  final String name;
  final String longName;
  final int? identifier;

  const TimeTablePeriodSubjectInformation(
    this.name,
    this.longName,
    this.identifier,
  );

  TimeTablePeriodSubjectInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longname'],
        identifier = json['id'];

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "longname": longName,
      "id": identifier,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimeTablePeriodSubjectInformation &&
          runtimeType == other.runtimeType &&
              name == other.name &&
              longName == other.longName &&
              identifier == other.identifier;

  @override
  int get hashCode => Object.hash(name, longName, identifier);
}

///Information about the period's room.
@immutable
class TimeTablePeriodRoomInformation {
  final String name;
  final String longName;
  final int? identifier;

  const TimeTablePeriodRoomInformation(
    this.name,
    this.longName,
    this.identifier,
  );

  TimeTablePeriodRoomInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longname'],
        identifier = json['id'];

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "longname": longName,
      "id": identifier,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimeTablePeriodRoomInformation &&
          runtimeType == other.runtimeType &&
              name == other.name &&
              longName == other.longName &&
              identifier == other.identifier;

  @override
  int get hashCode => Object.hash(name, longName, identifier);
}
