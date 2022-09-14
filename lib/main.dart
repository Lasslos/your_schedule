import 'package:flutter/material.dart';
import 'package:your_schedule/ui/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dein Stundenplan',
      home: HomeScreen(),
    );
  }
}
