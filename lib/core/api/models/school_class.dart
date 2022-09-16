class SchoolClass {
  ///Üblicherweise 1: Klasse
  final int type;

  ///Die ID der Klasse
  final int id;

  ///Name der Klasse: BS FI 21A
  final String name;

  ///Displayname: BS FI 21A
  final String displayName;

  ///Kürzel des Klassenlehrers. Üblicherweise 3 Buchstaben
  final String? classTeacherName;

  ///Der Nachnahme des Lehrers
  final String? classTeacherLongName;

  ///Kürzel des zweiten Klassenlehrers. Üblicherweise 3 Buchstaben
  ///Nullable
  final String? classTeacher2Name;

  ///Der Nachnahme des zweiten Klassenlehrers
  ///Nullable
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
