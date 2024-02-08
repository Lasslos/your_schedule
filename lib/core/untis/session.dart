import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/untis.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
sealed class Session with _$Session {
  const factory Session.active(
    School school,
    String username,
    String password,
    String appSharedSecret,
    UserData userData,
  ) = ActiveSession;

  const factory Session.inactive({
    required School school,
    required String username,
    required String password,
  }) = InactiveSession;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
