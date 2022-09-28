import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.message, super.key});

  final String message;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var loginFieldController = TextEditingController();
  var passwordFieldController = TextEditingController();
  var schoolFieldController = TextEditingController();
  var domainFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Login",
                      style: textTheme.headline3
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Melde dich mit deinem Untis-Konto an",
                      style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  TextField(
                    autocorrect: false,
                    autofillHints: const ["EF", "Q1", "Q2"],
                    keyboardType: TextInputType.text,
                    controller: loginFieldController,
                    decoration: const InputDecoration(
                        labelText: "Benutzername",
                        hintText: "Q1",
                        prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordFieldController,
                    decoration: const InputDecoration(
                      labelText: "Passwort",
                      hintText: "•••••••",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    controller: schoolFieldController,
                    decoration: const InputDecoration(
                        labelText: "Schule",
                        hintText: "cjd-königswinter",
                        prefixIcon: Icon(Icons.school)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    controller: domainFieldController,
                    decoration: InputDecoration(
                      labelText: "Domain",
                      hintText: "https://?.webuntis.com",
                      prefixIcon: const Icon(Icons.domain),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          openExplainingDialog();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ///TODO: Add submit button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openExplainingDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("How do I find the domain?"),

              ///TODO: Remove lorem ipsum
              content: const Text(
                  "Well idk man but here is some lorem ipsum: Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Ok", textAlign: TextAlign.end),
                ),
              ],
            ));
  }
}
