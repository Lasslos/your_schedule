import 'package:flutter/material.dart';

@immutable
class ProfileData {
  final String displayName;
  final String? imageURL;
  final String? schoolLongName;
  final int? schoolId;

  ///Konstruiert einen [ProfileData] aus einer [Map] mit den Schlüsseln `user-person-displayName`, `user-person-imageUrl`, `tenant-displayName` und `tenant-id`.
  ///Dies ist unsicher, wenn die Map diese Schlüssel nicht enthält.
  ProfileData.fromJSON(Map<String, dynamic> json)
      : assert(json.isNotEmpty, "json must not be empty"),
        assert(json['errorMessage'] == null, json['errorMessage']),
        displayName = json['user']['person']['displayName'],
        imageURL = json['user']['person']['imageUrl'],
        schoolLongName = json['tenant']['displayName'],
        schoolId = json['tenant']['id'];

  const ProfileData.empty()
      : displayName = "",
        imageURL = null,
        schoolLongName = null,
        schoolId = null;
}
