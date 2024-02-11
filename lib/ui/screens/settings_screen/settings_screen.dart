import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/provider/custom_subject_colors.dart';
import 'package:your_schedule/settings/sentry_provider.dart';
import 'package:your_schedule/settings/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text("Einstellungen"),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                "Design",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
              ),
            ),
            ListTile(
              title: const Text("Design"),
              subtitle: Text(
                switch (ref.watch(themeSettingProvider)) { ThemeMode.system => "Systemvorgabe", ThemeMode.light => "Hell", ThemeMode.dark => "Dunkel" },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Design"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text("Systemvorgabe"),
                          value: ThemeMode.system,
                          groupValue: ref.watch(themeSettingProvider),
                          onChanged: (value) {
                            ref.read(themeSettingProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Hell"),
                          value: ThemeMode.light,
                          groupValue: ref.watch(themeSettingProvider),
                          onChanged: (value) {
                            ref.read(themeSettingProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Dunkel"),
                          value: ThemeMode.dark,
                          groupValue: ref.watch(themeSettingProvider),
                          onChanged: (value) {
                            ref.read(themeSettingProvider.notifier).setTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Farben zurücksetzen"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Farben zurücksetzen"),
                    content: const Text(
                      "Möchtest du wirklich alle Farben der Fächer zurücksetzen?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Abbrechen"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref.read(customSubjectColorsProvider.notifier).reset();
                        },
                        child: const Text("Zurücksetzen"),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                "Sonstiges",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
              ),
            ),
            ListTile(
              title: const Text("Fehlerberichte senden"),
              subtitle: ref.watch(sentrySettingsProvider) == true ? const Text("Aktiviert") : const Text("Deaktiviert"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Fehlerberichte senden?"),
                      content: const Text("Stundenplan wird kontinuierlich verbessert. Wir verwenden Sentry, um Fehlerberichte zu sammeln. "
                          "Fehlerberichte helfen uns dabei, Probleme zu erkennen und zu beheben. Dafür benötigen wir jedoch deine Zustimmung. "
                          "Du kannst deine Zustimmung jederzeit in den Einstellungen wiederrufen. Die Einstellung wird mit einem App-Neustart aktiv. Möchtest du Fehlerberichte senden?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            ref.read(sentrySettingsProvider.notifier).setSentryEnabled(true);
                            Navigator.pop(context);
                          },
                          child: const Text("Ja"),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(sentrySettingsProvider.notifier).setSentryEnabled(false);
                            Navigator.pop(context);
                          },
                          child: const Text("Nein"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
}
