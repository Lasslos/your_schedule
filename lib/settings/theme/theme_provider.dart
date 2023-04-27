import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

StateNotifierProvider<ThemeProvider, ThemeMode> themeProvider =
    StateNotifierProvider<ThemeProvider, ThemeMode>((ref) => ThemeProvider());

class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system);

  void setTheme(ThemeMode theme) {
    if (theme != ThemeMode.system) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('darkMode', theme == ThemeMode.dark);
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('darkMode');
      });
    }
    state = theme;
  }
}
