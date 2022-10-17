import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: const Center(
          child: Text(
            "Hier gibt es noch nichts.\nSuchst du eine Einstellung?\nSchreib mir, damit ich das implementieren kann!",
            textAlign: TextAlign.center,
          ),
        ),
      );
}
