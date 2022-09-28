import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/ui/screens/loading_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dein Stundenplan',
      home: const LoadingScreen(),
      theme: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
