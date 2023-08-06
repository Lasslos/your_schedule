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
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_state_provider.dart';
import 'package:your_schedule/ui/screens/login_screen/welcome_widget.dart';
import 'package:your_schedule/util/logger.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: ref.watch(loginStateProvider).currentPage == 1
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(
                          currentPage: 0,
                          message: '',
                        );
                  },
                ),
              )
            : null,
        body: PageTransitionSwitcher(
          transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          child: ref.watch(loginStateProvider).currentPage == 0 ? const _SelectSchoolScreen() : const _LoginScreen(),
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
  final TextEditingController _schoolFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _welcomeKey = GlobalKey<WelcomeWidgetState>();

  bool showSchoolList = false;
  List<School> _possibleSchools = [];
  String? _errorMessage;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            controller: _scrollController,
            children: [
              WelcomeWidget(key: _welcomeKey),
              TextField(
                autocorrect: false,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.fullStreetAddress,
                ],
                controller: _schoolFieldController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: "Schulname oder Adresse",
                  errorText: _errorMessage,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (s) async {
                  if (s.length < 3) {
                    setState(() {
                      _possibleSchools = [];
                      _errorMessage = null;
                      showSchoolList = false;
                    });
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    return;
                  }
                  var connectivityResult = await ref.read(connectivityProvider.future);
                  if (connectivityResult == ConnectivityResult.none) {
                    setState(() {
                      _errorMessage = "Keine Internetverbindung";
                    });
                    return;
                  }

                  try {
                    var schools = await requestSchoolList(s);
                    setState(() {
                      showSchoolList = true;
                      _possibleSchools = schools;
                      _errorMessage = null;
                    });
                    _scrollController.animateTo(
                      _welcomeKey.currentContext!.size!.height - 16,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } on RPCError catch (e, s) {
                    if (e.code == tooManyResults) {
                      return;
                    }
                    Sentry.captureException(e, stackTrace: s);
                    getLogger().e("Error while requesting school list", e, s);
                    setState(() {
                      _errorMessage = e.message;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 16,
              ),
              if (showSchoolList)
                for (var school in _possibleSchools)
                  ListTile(
                    title: Text(school.displayName),
                    subtitle: Text(school.address),
                    onTap: () {
                      ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider.notifier).state.copyWith(
                            school: school,
                            currentPage: 1,
                          );
                    },
                  ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _schoolFieldController.dispose();
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

    var connectivityResult = await ref.read(connectivityProvider.future);
    if (connectivityResult == ConnectivityResult.none) {
      ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider.notifier).state.copyWith(message: "Keine Internetverbindung");
      setState(() {
        isLoading = false;
      });
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
      //ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FilterScreen()),
      );
    } on RPCError catch (e, s) {
      if (e.code == badCredentials) {
        ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(message: "Falsches Passwort");
      } else {
        Sentry.captureException(e, stackTrace: s);
        getLogger().e("RPCError while logging in", e, s);
        ref.read(loginStateProvider.notifier).state = ref.read(loginStateProvider).copyWith(message: e.message);
      }
    } catch (e, s) {
      Sentry.captureException(e, stackTrace: s);
      getLogger().e("Unknown Error while logging in", e, s);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
