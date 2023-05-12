import 'package:flutter/material.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  @override
  State<WelcomeWidget> createState() => WelcomeWidgetState();
}

class WelcomeWidgetState extends State<WelcomeWidget> {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 4,
            ),
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: Image.asset(
              'assets/school_blue.png',
            ),
          ),
          Text(
            'Willkommen in der App Stundenplan!',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Dein Stundenplan ist nur noch ein paar Klicks entfernt.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      );
}
