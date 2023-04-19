import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

@freezed
class Teacher with _$Teacher {
  const factory Teacher({
    required int id,
    required String name,
    required String firstName,
    required String longName,
    required bool active,
  }) = _Teacher;

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);
}
