import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

@freezed
class School with _$School {
  const factory School({
    required String server,
    required String address,
    required String displayName,
    required String loginName,
    required int schoolId,
    required String serverUrl,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}
