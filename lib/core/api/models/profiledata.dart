class ProfileData {
  ///Der vollständige Name. Der Nachname kommt vor dem Vornahmen.
  ///
  ///Z.B. `"Lustig Peter"`
  String displayName;

  ///Die URL des Profilbildes
  ///
  ///Z.B. `https://images.webuntis.com/image/5539000/awd4ou5rt23orw8torw978sefg`
  String? imageURL;

  ///Der Name der Schule
  ///
  ///Z.B. `"CJD Königswinter"`
  String? schoolLongName;

  ///Die ID der Schule.
  ///
  ///Z.B. `18696`
  int? schoolId;

  ProfileData._(
      this.displayName, this.imageURL, this.schoolLongName, this.schoolId);

  ProfileData.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        displayName = json['user']['person']['displayName'],
        imageURL = json['user']['person']['imageUrl'],
        schoolLongName = json['tenant']['displayName'],
        schoolId = json['tenant']['id'];
}
