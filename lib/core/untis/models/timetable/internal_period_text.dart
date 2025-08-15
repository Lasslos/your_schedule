import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'internal_period_text.freezed.dart';
part 'internal_period_text.g.dart';

@freezed
abstract class InternalPeriodText with _$InternalPeriodText {
  const factory InternalPeriodText(
    String lesson,
    String substitution,
    String info,
  ) = _InternalPeriodText;

  factory InternalPeriodText.fromJson(Map<String, dynamic> json) =>
      _$InternalPeriodTextFromJson(json);
}
