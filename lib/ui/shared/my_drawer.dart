import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/profile_data.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/ui/screens/settings_screen/settings_screen.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Widget avatar = getProfileAvatar(context, ref);
    String username =
        ref.watch(userSessionProvider.select((value) => value.username));
    String school =
        ref.watch(userSessionProvider.select((value) => value.school));
    ProfileData? profileData =
        ref.watch(userSessionProvider.select((value) => value.profileData));

    if (profileData != null && profileData.displayName.isNotEmpty) {
      username = profileData.displayName;
    }
    if (profileData != null &&
        profileData.schoolLongName != null &&
        profileData.schoolLongName!.isNotEmpty) {
      school = profileData.schoolLongName!;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(school),
            currentAccountPicture: avatar,
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
              ref.read(userSessionProvider.notifier).logout();
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
