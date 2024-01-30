import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    if (theme == ThemeMode.system) {
      prefs.remove('darkMode');
      return;
    }

    prefs.setBool('darkMode', theme == ThemeMode.dark);
  }
}
