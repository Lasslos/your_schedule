import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'internal_user_data.freezed.dart';
part 'internal_user_data.g.dart';

@freezed
class InternalUserData with _$InternalUserData {
  const factory InternalUserData(
    String displayName,
    String schoolName,
  ) = _InternalUserData;

  factory InternalUserData.fromJson(Map<String, dynamic> json) =>
      _$InternalUserDataFromJson(json);
}
