import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/settings/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text("Einstellungen"),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
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
            ListTile(
              title: const Text("Design"),
              subtitle: Text(() {
                switch (ref.watch(themeProvider)) {
                  case ThemeMode.system:
                    return "Systemvorgabe";
                  case ThemeMode.light:
                    return "Hell";
                  case ThemeMode.dark:
                    return "Dunkel";
                }
              }()),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Design"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text("Hell"),
                          value: ThemeMode.light,
                          groupValue: ref.watch(themeProvider),
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Dunkel"),
                          value: ThemeMode.dark,
                          groupValue: ref.watch(themeProvider),
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Systemvorgabe"),
                          value: ThemeMode.system,
                          groupValue: ref.watch(themeProvider),
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
}
