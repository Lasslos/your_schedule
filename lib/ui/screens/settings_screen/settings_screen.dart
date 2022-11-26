import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/settings/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Text(
                "General",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.8),
                    ),
              ),
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                ref.read(themeProvider.notifier).setTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ],
        ),
      );
}
