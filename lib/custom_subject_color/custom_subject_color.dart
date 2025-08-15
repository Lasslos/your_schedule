import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_subject_color.freezed.dart';
part 'custom_subject_color.g.dart';

@freezed
abstract class CustomSubjectColor with _$CustomSubjectColor {
  const factory CustomSubjectColor(
    int subjectId,
    @ColorConverter() Color color,
    @ColorConverter() Color textColor,
  ) = _CustomSubjectColor;

  const CustomSubjectColor._();

  factory CustomSubjectColor.fromJson(Map<String, dynamic> json) =>
      _$CustomSubjectColorFromJson(json);

  static const CustomSubjectColor regularColor = CustomSubjectColor(
    -1,
    Colors.lightGreen,
    Colors.white,
  );
  static final CustomSubjectColor examColor = CustomSubjectColor(
    -1,
    Colors.red[900]!,
    Colors.white,
  );
  static const CustomSubjectColor irregularColor = CustomSubjectColor(
    -1,
    Colors.orange,
    Colors.white,
  );
  static const CustomSubjectColor cancelledColor = CustomSubjectColor(
    -1,
    Colors.red,
    Colors.white,
  );
  static const CustomSubjectColor emptyColor = CustomSubjectColor(
    -1,
    Colors.grey,
    Colors.black,
  );
}

class ColorConverter extends JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.value;
  }
}
