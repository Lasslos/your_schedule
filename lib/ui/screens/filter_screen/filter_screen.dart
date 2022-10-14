import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Filter Settings"),
    ),
    body: ListView(
      children: const [
        ///TODO: Obvious
        Text("If not set up: Run setup"),
        Text("Else"),
        Text("Current filters"),
        Text("Add filter"),
        Text("Clear filters and run setup")
      ],
    ),
  );
}
