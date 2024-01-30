import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/custom_subject_color/custom_subject_color.dart';
import 'package:your_schedule/migration_core/custom_subject_colors.dart' as old_custom_subject_colors;
import 'package:your_schedule/migration_core/filter.dart';
import 'package:your_schedule/migration_core/timetable_period_subject_information.dart';
import 'package:your_schedule/ui/screens/login_screen/login_state_provider.dart';
import 'package:your_schedule/utils.dart';

//The current version of the app. Change this constant if the SharedPreferences should be migrated.
const String _currentVersion = '1.3.*';

Future<void> migrate(SharedPreferences prefs, WidgetRef ref, BuildContext context) async {
  String? version = prefs.getString('version');
  if (version == _currentVersion) {
    return;
  }

  Set<TimeTablePeriodSubjectInformation> filterItems = initializeFilters(prefs);
  Map<TimeTablePeriodSubjectInformation, old_custom_subject_colors.CustomSubjectColor> customSubjectColors =
      old_custom_subject_colors.initializeCustomSubjectColors(prefs);

  String? username = await secureStorage.read(key: usernameKey);
  String? password = await secureStorage.read(key: passwordKey);
  String? schoolName = await secureStorage.read(key: schoolKey);
  String? apiBaseURl = await secureStorage.read(key: apiBaseURlKey);

  if (username == null || password == null || schoolName == null || apiBaseURl == null) {
    return;
  }

  School? school;
  try {
    school = (await requestSchoolList(schoolName)).firstOrNull;
  } catch (e, s) {
    logRequestError("Error while fetching school list", e, s);
    rethrow;
  }
  if (school == null) {
    return;
  }

  var session = Session.inactive(
    school: school,
    username: username,
    password: password,
  );

  var connectionState = await ref.read(connectivityProvider.future);
  if (connectionState == ConnectivityResult.none) {
    return;
  }

  try {
    session = await activateSession(ref, session);
    ref.read(sessionsProvider.notifier).addSession(session);

    var subjects = session.userData!.subjects;
    Set<int> newFilters = {};
    subjects.forEach((key, value) {
      if (!filterItems.any((element) => element.name == value.name)) {
        newFilters.add(key);
      }
    });
    ref.read(filtersProvider.notifier).addAll(newFilters.toList());

    Map<int, CustomSubjectColor> newCustomSubjectColors = {};
    subjects.forEach((newId, newSubject) {
      var element = customSubjectColors.entries.firstWhereOrNull((element) => element.key.name == newSubject.name);
      if (element != null) {
        newCustomSubjectColors[newId] = CustomSubjectColor(
          newId,
          element.value.color,
          element.value.textColor,
        );
      }
    });
    ref.read(customSubjectColorsProvider.notifier).addAll(newCustomSubjectColors);

  } on RPCError catch (e, s) {
    getLogger().e("Migration failed", error: e, stackTrace: s);
    ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(
          message: e.code == RPCError.authenticationFailed ? "Falsches Passwort" : e.message,
        );
  } catch (e, s) {
    getLogger().e("Migration failed", error: e, stackTrace: s);
    return;
  }
  prefs.setString("version", _currentVersion);
}
