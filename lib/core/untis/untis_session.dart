import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/untis.dart';

part 'untis_session.freezed.dart';
part 'untis_session.g.dart';

@freezed
sealed class UntisSession with _$UntisSession {
  const factory UntisSession.active(
    School school,
    String username,
    String password,
    String appSharedSecret,
    UserData userData,) = ActiveUntisSession;

  const factory UntisSession.inactive({
    required School school,
    required String username,
    required String password,
  }) = InactiveUntisSession;

  factory UntisSession.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
