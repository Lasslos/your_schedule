import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/util/string_utils.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

@freezed
class Teacher with _$Teacher {
  const factory Teacher(
    @JsonKey(name: "name") String shortName,
    String firstName,
    String lastName,
    bool active,
  ) = _Teacher;

  const Teacher._();

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);

  String get longName =>
      "${firstName.toLowerCase().capitalizeFirst()} ${lastName.toLowerCase().capitalizeFirst()}";
}
