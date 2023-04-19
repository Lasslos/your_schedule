import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'klasse.freezed.dart';
part 'klasse.g.dart';

@freezed
class Klasse with _$Klasse {
  const factory Klasse({
    required int id,
    required String name,
    required String longName,
    required DateTime startDate,
    required DateTime endDate,
    required bool active,
  }) = _Klasse;

  factory Klasse.fromJson(Map<String, dynamic> json) => _$KlasseFromJson(json);
}
