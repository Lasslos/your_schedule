import 'package:flutter/material.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => WelcomeWidgetState();
}

class WelcomeWidgetState extends State<WelcomeWidget> {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 5,
        ),
        margin: const EdgeInsets.symmetric(vertical: 32),
        child: Image.asset(
          'assets/school_blue.png',
        ),
      ),
      Text(
        'Willkommen bei\nUntis Connect!',
        style: Theme.of(context).textTheme.displaySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
