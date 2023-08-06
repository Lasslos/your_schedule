//ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc_error.dart';
import 'package:your_schedule/core/session/custom_subject_colors.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
import 'package:your_schedule/core/untis/untis_api.dart';
import 'package:your_schedule/migration_core/migrate.dart';
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/util/logger.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  String _message = "Loading session";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      login();
    });
  }

  //Hier wird der login mit gespeicherten Daten versucht
  Future<void> login() async {
    getLogger().i("Loading screen started");
    await migrate(await SharedPreferences.getInstance(), ref, context);

    List<Session> sessions = [];

    //Load sessions from shared prefs
    try {
      await ref.read(sessionsProvider.notifier).initializeFromSharedPrefs();
      sessions = ref.read(sessionsProvider);
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while parsing session json", e, s);
    }
    if (sessions.isEmpty) {
      setState(() {
        _message = "No sessions found";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    }

    //Load filters and custom subject colors from shared prefs
    setState(() {
      _message = "Loading data";
    });
    try {
      await ref.read(filtersProvider.notifier).initializeFromPrefs();
      await ref.read(customSubjectColorsProvider.notifier).initializeFromPrefs();
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while parsing json", e, s);
    }

    //Load data from untis
    setState(() {
      _message = "Refreshing session";
    });
    final connectivityResult = await ref.read(connectivityProvider.future);
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await refreshSession(ref, sessions.first);
      } on RPCError catch (e, s) {
        await _onRPCError(sessions, e, s);
        return;
      } on SocketException catch (e, s) {
        getLogger().w("SocketException while refreshing session", e, s);
        setState(() {
          _message = "No internet connection, using cached data";
        });
        Sentry.captureEvent(
          SentryEvent(
            message: const SentryMessage("SocketException while refreshing session"),
            level: SentryLevel.warning,
            exceptions: [
              SentryException(
                type: e.runtimeType.toString(),
                value: e.toString(),
                throwable: e,
              ),
            ],
          ),
        );
      } on TimeoutException catch (e, s) {
        _message = "No internet connection, using cached data";
        getLogger().w("TimeoutException while refreshing session", e, s);
        Sentry.captureEvent(
          SentryEvent(
            message: const SentryMessage("TimeoutException while refreshing session"),
            level: SentryLevel.warning,
            exceptions: [
              SentryException(
                type: e.runtimeType.toString(),
                value: e.toString(),
                throwable: e,
              ),
            ],
          ),
        );
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        getLogger().e("Error while refreshing session", e, s);
        setState(() {});
      }
    } else {
      setState(() {
        _message = "No internet connection, using cached data";
      });
    }

    var filters = ref.read(filtersProvider);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
    );
    if (filters.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FilterScreen()),
      );
    }
  }

  Future<void> _onRPCError(List<Session> sessions, RPCError e, StackTrace s) async {
    if (e.code != badCredentials) {
      await Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while refreshing session", e, s);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    }

    getLogger().w("Bad credentials, reauthenticating");
    setState(() {
      _message = "Bad credentials, reauthenticating";
    });
    var session = sessions.first;
    var newSession = Session.inactive(
      username: session.username,
      password: session.password,
      school: session.school,
    );
    try {
      //Trying to reauthenticate
      ref.read(sessionsProvider.notifier).updateSession(session, await activateSession(ref, newSession));
    } on RPCError catch (e, s) {
      //Reauthentication failed, deleting session
      if (e.code == badCredentials) {
        setState(() {
          _message = "Bad credentials, deleting session";
        });
        getLogger().w("Bad credentials, deleting session");
        ref.read(sessionsProvider.notifier).removeSession(session);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Deine Anmeldedaten sind ungültig, bitte melde dich erneut an.", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ),
        );
        return;
      }

      //A different RPCError occurred while reauthenticating
      Sentry.captureException(e, stackTrace: s);
      getLogger().e("RPCError while reauthenticating", e, s);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    } catch (e, s) {
      //An unknown error occurred while reauthenticating
      Sentry.captureException(e, stackTrace: s);
      getLogger().e("Unknown Error while reauthenticating", e, s);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    }
    getLogger().i("Reauthenticated");
    var filters = ref.read(filtersProvider);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
    );
    if (filters.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FilterScreen()),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 200,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/school_blue.png"),
              ),
            ),
            const Spacer(flex: 1),
            const CircularProgressIndicator(),
            const SizedBox(height: 25),
            Text(
              _message,
              style: GoogleFonts.lato(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
