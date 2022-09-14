class SchoolClass {
  ///Üblicherweise 1: Klasse
  int type;

  ///Die ID der Klasse
  int id;

  ///Name der Klasse: BS FI 21A
  String name;

  ///Displayname: BS FI 21A
  String displayName;

  ///Kürzel des Klassenlehrers. Üblicherweise 3 Buchstaben
  String? classTeacherName;

  ///Der Nachnahme des Lehrers
  String? classTeacherLongName;

  ///Kürzel des zweiten Klassenlehrers. Üblicherweise 3 Buchstaben
  ///Nullable
  String? classTeacher2Name;

  ///Der Nachnahme des zweiten Klassenlehrers
  ///Nullable
  String? classTeacher2LongName;

  SchoolClass._(
      this.type,
      this.id,
      this.name,
      this.displayName,
      this.classTeacherName,
      this.classTeacherLongName,
      this.classTeacher2Name,
      this.classTeacher2LongName);

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
