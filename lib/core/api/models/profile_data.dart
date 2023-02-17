import 'package:flutter/material.dart';

@immutable
class ProfileData {
  final String displayName;
  final String? imageURL;
  final String? schoolLongName;
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
