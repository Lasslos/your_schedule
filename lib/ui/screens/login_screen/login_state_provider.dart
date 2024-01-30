import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/core/untis.dart';

part 'login_state_provider.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default(0) int currentPage,
    @Default('') String message,
    @Default(null) School? school,
  }) = _LoginState;
}

final loginStateProvider = StateProvider.autoDispose<LoginState>((ref) => const LoginState());
