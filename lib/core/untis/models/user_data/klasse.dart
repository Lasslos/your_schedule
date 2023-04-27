import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'klasse.freezed.dart';
part 'klasse.g.dart';

@freezed
class Klasse with _$Klasse {
  const factory Klasse(
    String name,
    String longName,
    DateTime startDate,
    DateTime endDate,
    bool active,
  ) = _Klasse;

  factory Klasse.fromJson(Map<String, dynamic> json) => _$KlasseFromJson(json);
}
