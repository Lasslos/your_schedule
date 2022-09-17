///Information about the period's school class.
class TimeTablePeriodSchoolClassInformation {
  String name;
  String longName;
  int? identifier;

  TimeTablePeriodSchoolClassInformation(
      this.name, this.longName, this.identifier);

  TimeTablePeriodSchoolClassInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longName'],
        identifier = json['id'];
}

///Information about the period's teacher.
class TimeTablePeriodTeacherInformation {
  String name;
  String longName;
  int? identifier;

  TimeTablePeriodTeacherInformation(this.name, this.longName, this.identifier);

  TimeTablePeriodTeacherInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longName'],
        identifier = json['id'];
}

///Information about the period's subject.
class TimeTablePeriodSubjectInformation {
  String name;
  String longName;
  int? identifier;

  TimeTablePeriodSubjectInformation(this.name, this.longName, this.identifier);

  TimeTablePeriodSubjectInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longName'],
        identifier = json['id'];
}

///Information about the period's room.
class TimeTablePeriodRoomInformation {
  String name;
  String longName;
  int? identifier;

  TimeTablePeriodRoomInformation(this.name, this.longName, this.identifier);

  TimeTablePeriodRoomInformation.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        name = json['name'].toString(),
        longName = json['longName'],
        identifier = json['id'];
}
