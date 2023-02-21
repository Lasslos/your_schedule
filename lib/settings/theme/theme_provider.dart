import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

StateNotifierProvider<ThemeProvider, ThemeMode> themeProvider =
    StateNotifierProvider<ThemeProvider, ThemeMode>((ref) => ThemeProvider());
//Hier wird die Helligkeit der App gespeichert.
class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system);

  void setTheme(ThemeMode theme) {
    //Hier wird das Theme in den SharedPreferences gespeichert
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
