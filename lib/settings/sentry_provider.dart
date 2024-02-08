import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/util/shared_preferences.dart';

part 'sentry_provider.g.dart';

@riverpod
class SentrySettings extends _$SentrySettings {
  @override
  bool build() {
    return sharedPreferences.getBool('sentryEnabled') ?? false;
  }

  Future<void> setSentryEnabled(bool enabled) async {
    state = enabled;
    await sharedPreferences.setBool('sentryEnabled', enabled);
  }
}
