import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:your_schedule/util/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    if (theme == ThemeMode.system) {
      await sharedPreferences.remove('darkMode');
      return;
    }

    await sharedPreferences.setBool('darkMode', theme == ThemeMode.dark);
  }
}
