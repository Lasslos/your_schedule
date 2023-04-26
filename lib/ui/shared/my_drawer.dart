import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/ui/screens/settings_screen/settings_screen.dart';
import 'package:your_schedule/untis/models/user_data/user_data.dart';
import 'package:your_schedule/untis/providers/app_shared_secret_provider.dart';
import 'package:your_schedule/untis/providers/user_data_provider.dart';
import 'package:your_schedule/user_profiles/user_profile.dart';
import 'package:your_schedule/user_profiles/user_profiles_provider.dart';
import 'package:your_schedule/util/logger.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    UserProfile userProfile = ref.watch(
        userProfilesProvider.select((value) => value.selectedUserProfile));
    var appSharedSecret = ref.watch(
      appSharedSecretProvider(
        userProfile.appSharedSecretParams,
      ),
    );
    if (appSharedSecret.hasError) {
      Sentry.captureException(
        appSharedSecret.error,
        stackTrace: appSharedSecret.stackTrace,
      );
      getLogger().e(appSharedSecret.error, appSharedSecret.stackTrace);
      return const Drawer(
        child: Center(
          child: Text("Fehler beim Laden des AppSharedSecrets"),
        ),
      );
    }
    if (appSharedSecret.isLoading) {
      return const Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var userData = ref.watch(
      userDataProvider(
        userProfile.getAuthenticatedRPCRequestScaffold(
          appSharedSecret.requireValue,
        ),
      ),
    );

    if (userData.hasError) {
      Sentry.captureException(
        userData.error,
        stackTrace: userData.stackTrace,
      );
      getLogger().e(userData.error, userData.stackTrace);
      return const Drawer(
        child: Center(
          child: Text("Fehler beim Laden der Benutzerdaten"),
        ),
      );
    }
    if (userData.isLoading) {
      return const Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    UserData userDataValue = userData.requireValue;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userDataValue.displayName),
            accountEmail: Text(userProfile.username),
            decoration: BoxDecoration(
              color: Colors.lightBlue[500],
            ),
          ),
          ListTile(
            title: const Text("Stundenplan"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Filter"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterScreen(),
                ),
              );
            },
          ),
          Expanded(child: Container()),
          ListTile(
            title: const Text("Einstellungen"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              "Logout",
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              ref.read(userProfilesProvider.notifier).remove(userProfile);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(message: ""),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getProfileAvatar(BuildContext context, WidgetRef ref) {
    return CircleAvatar(
      backgroundColor: Colors.lightBlue[300],
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
