import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc_error.dart';
import 'package:your_schedule/core/session/custom_subject_colors.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/models/school_search/school.dart';
import 'package:your_schedule/core/untis/requests/request_app_shared_secret.dart';
import 'package:your_schedule/core/untis/requests/request_school_list.dart';
import 'package:your_schedule/custom_subject_color/custom_subject_color.dart';
import 'package:your_schedule/migration_core/custom_subject_colors.dart' as old_custom_subject_colors;
import 'package:your_schedule/migration_core/filter.dart';
import 'package:your_schedule/migration_core/timetable_period_subject_information.dart';
import 'package:your_schedule/ui/screens/login_screen/login_state_provider.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/secure_storage_util.dart';

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

  School? school = (await requestSchoolList(schoolName)).firstOrNull;
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
    getLogger().e("Migration failed", e, s);
    if (e.code == badCredentials) {
      ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(message: "Falsches Passwort");
    } else {
      Sentry.captureException(e, stackTrace: s);
      ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(message: e.message);
    }
  } catch (e, s) {
    getLogger().e("Migration failed", e, s);
    Sentry.captureException(e, stackTrace: s);
    return;
  }
  prefs.setString("version", _currentVersion);
}
