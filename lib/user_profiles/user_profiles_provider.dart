import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_schedule/user_profiles/user_profile.dart';
import 'package:flutter/foundation.dart';

part 'user_profiles_provider.freezed.dart';

@freezed
class Session with _$Session {
  const factory Session(
    UserProfile profile,
    String appSharedSecret,
    bool hasValidAppSharedSecret,
  ) = _Session;
}

class UserProfilesNotifier extends StateNotifier<List<UserProfile>> {
  UserProfilesNotifier() : super([]);

  void add(UserProfile userProfile) {
    state = [...state, userProfile];
  }

  void remove(UserProfile userProfile) {
    state = state.where((element) => element != userProfile).toList();
  }

  void select(UserProfile userProfile) {
    state = [
      userProfile,
      ...state.where((element) => element != userProfile).toList()
    ];
  }
}

extension SelectedUserProfile on List<UserProfile> {
  UserProfile get selectedUserProfile => this[0];
}

final userProfilesProvider =
    StateNotifierProvider<UserProfilesNotifier, List<UserProfile>>((ref) {
  return UserProfilesNotifier();
});
