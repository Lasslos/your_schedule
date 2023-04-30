import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc_error.dart';
import 'package:your_schedule/core/session/custom_subject_colors.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/collapsable.dart';
import 'package:your_schedule/ui/screens/login_screen/login_state_provider.dart';
import 'package:your_schedule/util/logger.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: PageTransitionSwitcher(
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          child: ref.watch(loginStateProvider).currentPage == 0
              ? const _SelectSchoolScreen()
              : const _LoginScreen(),
        ),
      );
}

class _SelectSchoolScreen extends ConsumerStatefulWidget {
  const _SelectSchoolScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends ConsumerState<_SelectSchoolScreen> {
  final TextEditingController _controller = TextEditingController();
  bool showSchoolList = false;
  List<School> _possibleSchools = [];
  String? _errorMessage;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 16,
              ),
              Collapsable(
                isExpanded: !showSchoolList,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/school_blue.png',
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                    const SizedBox(
                      height: 16,
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
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                autocorrect: false,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.fullStreetAddress,
                ],
                controller: _controller,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  helperText: "Welche Schule besuchst du?",
                  hintText: "Schulname oder Adresse",
                  errorText: _errorMessage,
                  border: const OutlineInputBorder(),
                ),
                onTap: () {},
                onChanged: (s) async {
                  if (s.length < 3) {
                    setState(() {
                      _possibleSchools = [];
                      _errorMessage = null;
                      showSchoolList = false;
                    });
                    return;
                  }
                  setState(() {
                    showSchoolList = true;
                  });
                  try {
                    var schools = await requestSchoolList(s);
                    setState(() {
                      _possibleSchools = schools;
                      _errorMessage = null;
                    });
                  } on RPCError catch (e) {
                    setState(() {
                      _errorMessage = e.message;
                    });
                  }
                },
              ),
              if (showSchoolList)
                Expanded(
                  child: ListView(
                    children: [
                      for (var school in _possibleSchools)
                        ListTile(
                          title: Text(school.displayName),
                          subtitle: Text(school.address),
                          onTap: () {
                            ref.read(loginStateProvider.notifier).state = ref
                                .read(loginStateProvider.notifier)
                                .state
                                .copyWith(
                                  school: school,
                                  currentPage: 1,
                                );
                          },
                        ),
                    ],
                  ),
                )
            ],
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class _LoginScreen extends ConsumerStatefulWidget {
  const _LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<_LoginScreen> {
  late TextEditingController _usernameFieldController;
  late TextEditingController _passwordFieldController;
  var isLoading = false;
  var showPassword = false;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    _usernameFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    for (var i = 0; i < 3; i++) {
      focusNodes.add(FocusNode());
    }
    focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) => Center(
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
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Melde dich mit deinem Untis-Konto an",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    focusNode: focusNodes[0],
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: _usernameFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[0]);
                    },
                    decoration: const InputDecoration(
                      labelText: "Benutzername",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: focusNodes[1],
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: !showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    controller: _passwordFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[1]);
                    },
                    decoration: InputDecoration(
                      labelText: "Passwort",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: showPassword
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ref.watch(loginStateProvider).message,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.red),
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
                          focusNode: focusNodes[2],
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                            textStyle: MaterialStateProperty.all(
                              Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _login();
                          },
                          child: const Text("Log In"),
                        ),
                ],
              ),
            ),
          ),
        ),
      );

  void _login() async {
    setState(() {
      isLoading = true;
    });

    var connectivityResult = ref.read(connectivityProvider);
    if (connectivityResult is AsyncLoading ||
        connectivityResult.requireValue == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
      });
      //ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: SizedBox(
            height: 48,
            child: Center(child: Text("Keine Internetverbindung")),
          ),
        ),
      );
      return;
    }

    var school = ref.read(loginStateProvider).school!;
    Session session = Session.inactive(
      school: school,
      username: _usernameFieldController.text,
      password: _passwordFieldController.text,
    );

    try {
      session = await activateSession(ref, session);
      ref.read(sessionsProvider.notifier).addSession(session);

      try {
        await ref.read(filtersProvider.notifier).initializeFromPrefs();
        await ref
            .read(customSubjectColorsProvider.notifier)
            .initializeFromPrefs();
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        getLogger().e("Error while parsing json", e, s);
      }

      //ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on RPCError catch (e) {
      ref.read(loginStateProvider.notifier).state =
          ref.read(loginStateProvider).copyWith(message: e.message);
    } catch (e, s) {
      Sentry.captureException(e, stackTrace: s);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
