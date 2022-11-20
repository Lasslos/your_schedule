import 'package:flutter/material.dart';

/// Profile Data about the Student.
@immutable
class ProfileData {
  ///Der vollständige Name. Der Nachname kommt vor dem Vornahmen.
  ///
  ///Z.B. `"Lustig Peter"`
  final String displayName;

  ///Die URL des Profilbildes
  ///
  ///Z.B. `https://images.webuntis.com/image/5539000/awd4ou5rt23orw8torw978sefg`
  final String? imageURL;

  ///Der Name der Schule
  ///
  ///Z.B. `"CJD Königswinter"`
  final String? schoolLongName;

  ///Die ID der Schule.
  ///
  ///Z.B. `18696`
  final int? schoolId;

  ///Constructs a [ProfileData] from a [Map] with the keys `user-person-displayName`, `user-person-imageUrl`, `tenant-displayName` and `tenant-id` (lowercase).
  ///This is unsafe if the map does not contain these keys.
  ProfileData.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        displayName = json['user']['person']['displayName'],
        imageURL = json['user']['person']['imageUrl'],
        schoolLongName = json['tenant']['displayName'],
        schoolId = json['tenant']['id'];
}
