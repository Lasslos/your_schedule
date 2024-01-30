import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/untis.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class Exam with _$Exam {
  const factory Exam(
    int id,
    String? examType,
    DateTime startDateTime,
    DateTime endDateTime,
    int subjectId,
    List<int> klasseIds,
    Set<int> roomIds,
    List<int> teacherIds,
    List<Invigilators> invigilators,
    String name,
    String text,
  ) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
}
