import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Dein Stundenplan'),
        ),
        body: const Center(
          child: Text('Dein Stundenplan'),
        ),
      );
}
