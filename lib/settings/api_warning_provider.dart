import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/util/shared_preferences.dart';

part 'api_warning_provider.g.dart';

@riverpod
class ApiWarningShown extends _$ApiWarningShown {
  @override
  bool? build() {
    return sharedPreferences.getBool('apiWarningShown');
  }

  Future<void> setApiWarningShown(bool hasShown) async {
    state = hasShown;
    await sharedPreferences.setBool('apiWarningShown', hasShown);
  }
}
