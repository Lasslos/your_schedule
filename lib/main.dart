import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/settings/theme/theme_provider.dart';
import 'package:your_schedule/ui/screens/loading_screen/loading_screen.dart';

void main() async {
  //TODO: Add migration option from 1.2.* to 1.3.*
  //TODO: Connection banner to show last fetch
  Intl.defaultLocale = 'de';
  initializeDateFormatting('de_DE', null);
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  var darkMode = prefs.getBool('darkMode');
  var theme = darkMode == true
      ? ThemeMode.dark
      : darkMode != null
          ? ThemeMode.light
          : ThemeMode.system;

  /*await SentryFlutter.init(
    (options) {
      options
        ..dsn = 'https://1be6b663150041f6be6a7a4375e5599f@o4504990166155264.ingest.sentry.io/4504990173167616'
        ..tracesSampleRate = 1.0;
    },
    appRunner: () =>*/
  runApp(
    ProviderScope(
      child: MyApp(
        initialThemeMode: theme,
      ),
    ),
    //),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({required this.initialThemeMode, Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(themeProvider.notifier).setTheme(widget.initialThemeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Stundenplan',
      //Erster Screen: LoadingScreen
      home: const LoadingScreen(),
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: theme,
    );
  }
}
