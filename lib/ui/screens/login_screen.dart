import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/ui/screens/home_screen.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/secure_storage_util.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.message, super.key});

  final String message;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late String message;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    message = widget.message;
    focusNodes = List.generate(4, (index) => FocusNode());
    asyncInitialization();
  }

  Future<void> asyncInitialization() async {
    usernameFieldController.text =
        await secureStorage.read(key: usernameKey) ?? "";
    passwordFieldController.text =
        await secureStorage.read(key: passwordKey) ?? "";
    schoolFieldController.text = await secureStorage.read(key: schoolKey) ?? "";
    domainFieldController.text =
        await secureStorage.read(key: apiBaseURlKey) ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in focusNodes) {
      element.dispose();
    }
    usernameFieldController.dispose();
    passwordFieldController.dispose();
    schoolFieldController.dispose();
    domainFieldController.dispose();
  }

  var usernameFieldController = TextEditingController();
  var passwordFieldController = TextEditingController();
  var schoolFieldController = TextEditingController();
  var domainFieldController = TextEditingController();
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: textTheme.headline3
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Melde dich mit deinem Untis-Konto an",
                    style: textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: usernameFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[0]);
                    },
                    decoration: const InputDecoration(
                      labelText: "Benutzername",
                      hintText: "Q1",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: focusNodes[0],
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    controller: passwordFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[1]);
                    },
                    decoration: const InputDecoration(
                      labelText: "Passwort",
                      hintText: "•••••••",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: focusNodes[1],
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: schoolFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[2]);
                    },
                    decoration: InputDecoration(
                      labelText: "Schule",
                      hintText: "cjd-königswinter",
                      prefixIcon: const Icon(Icons.school),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          _openSchoolExplainingDialog();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: focusNodes[2],
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    controller: domainFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[3]);
                    },
                    decoration: InputDecoration(
                      labelText: "Domain",
                      hintText: "https://?.webuntis.com",
                      prefixIcon: const Icon(Icons.domain),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          _openDomainExplainingDialog();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: textTheme.labelMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: LinearProgressIndicator(),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          focusNode: focusNodes[3],
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              theme.colorScheme.primary,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              theme.colorScheme.onPrimary,
                            ),
                            textStyle:
                                MaterialStateProperty.all(textTheme.labelLarge),
                          ),
                          onPressed: _login,
                          child: const Text("Log In"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///TODO: Add school search. These help messages are great, but everyone is gonna hate them.

  void _login() {
    setState(() {
      isLoading = true;
    });
    var username = usernameFieldController.text.trim();
    var password = passwordFieldController.text.trim();
    var school = schoolFieldController.text.trim();
    var domain = domainFieldController.text.trim();
    if (!domain.startsWith("https://") || !domain.endsWith(".webuntis.com")) {
      setState(() {
        message =
            "Invalid domain: Must start with \"https://\" and end with \".webuntis.com\"";
        isLoading = false;
      });
      return;
    }

    ///Adding a virtual delay if an error message comes faster than 300ms.
    ///This prevents the loading animation snapping in and out of existence.
    Future.wait([
      loginAsync(username, password, school, domain),
      Future.delayed(const Duration(milliseconds: 300)),
    ]).then(
      (value) => setState(() {
        isLoading = false;
      }),
    );
  }

  Future<void> loginAsync(
    String username,
    String password,
    String school,
    String domain,
  ) async {
    try {
      await ref
          .read(userSessionProvider.notifier)
          .createSession(username, password, school, domain);
    } catch (e) {
      getLogger().e(e);

      ///Don't setState as this will be called by [_login]
      message = e.toString();
      return;
    }

    try {
      await ref.read(periodScheduleProvider.notifier).loadPeriodSchedule();
    } catch (e) {
      getLogger().e(e);
    }
    try {
      await ref.read(timeTableProvider.notifier).getTimeTableWeek(Week.now());
    } catch (e) {
      getLogger().e(e);
    }

    // This can be ignored as we use the context given by the state, meaning we don't store it.
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );

    ///Prevents the log in button being shown again before the page is replaced.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _openSchoolExplainingDialog() {
    _openExplainingDialog(
      "Wie finde ich den exakten Namen meiner Schule?",
      "Öffne die Website \nhttps://webuntis.com.\n"
          "Suche deine Schule.\n"
          "In dem Link, zu dem du weitergeleitet wurdest, steht \"school=\", "
          "gefolgt von dem Namen, den du brauchst.\n"
          "Es folgt ein #, welches nicht mehr Teil des Namens ist.",
    );
  }

  void _openDomainExplainingDialog() {
    _openExplainingDialog(
      "Wie finde ich die Domain?",
      "Öffne die Website \nhttps://webuntis.com.\n"
          "Suche deine Schule.\n"
          "Kopiere den Link, an den du weitergeleitet wurdest, das ist zum Beispiel https://herakles.webuntis.com...\n"
          "Entferne alles, was hinter dem \".com\" steht. "
          "Das ist die Domain.",
    );
  }

  void _openExplainingDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Ok", textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
