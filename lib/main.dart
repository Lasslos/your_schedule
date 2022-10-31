import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/ui/screens/loading_screen/loading_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ///TODO: Caching if no internet connection

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system,
    );
  }
}
