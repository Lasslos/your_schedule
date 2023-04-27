import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

@Freezed()
class School with _$School {
  const factory School(
    String server,
    String address,
    String displayName,
    String loginName,
    int schoolId,
    @JsonKey(name: 'serverUrl') String apiBaseUrl,
  ) = _School;

  const School._();

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}
