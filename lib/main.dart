import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/settings/theme/theme_provider.dart';
import 'package:your_schedule/ui/screens/loading_screen/loading_screen.dart';

void main() async {
  runApp(
    MaterialApp(
      home: const TempWidget(),
    ),
  );
  return;

  Intl.defaultLocale = 'de';
  initializeDateFormatting('de_DE', null);
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  var darkMode = prefs.getBool('darkMode');
  var theme = darkMode == true
      ? ThemeMode.dark
      : darkMode != null
          ? ThemeMode.light
          : null;
  runApp(ProviderScope(child: MyApp(initialThemeMode: theme)));
}

class MyApp extends ConsumerStatefulWidget {
  final ThemeMode? initialThemeMode;

  const MyApp({required this.initialThemeMode, Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ///TODO: Caching if no internet connection
  @override
  void initState() {
    super.initState();
    ref.read(themeProvider.notifier).setTheme(widget.initialThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Stundenplan',
      home: const LoadingScreen(),
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.lightBlue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: theme ?? ThemeMode.system,
    );
  }
}

class TempWidget extends StatelessWidget {
  const TempWidget({Key? key}) : super(key: key);

  //Create an evil-looking gradient background with large foreground text
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.5,
              center: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black.withRed(24),
                Colors.black.withRed(48),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: 1),
              Text(
                'Untis hat den Login blockiert.\n\nIch arbeite aber schon an einer Lösung.\n\nBis dahin bitte etwas Geduld.',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      );
}
