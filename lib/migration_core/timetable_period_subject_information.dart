///Informationen über das Fach, das in der Stunde unterrichtet wird.
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
