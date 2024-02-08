//ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/provider/connectivity_provider.dart';
import 'package:your_schedule/core/provider/filters.dart';
import 'package:your_schedule/core/provider/untis_session_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis/untis_session.dart';
import 'package:your_schedule/migration_core/migrate.dart';
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/utils.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({
    super.key,
  });

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

    List<UntisSession> sessions = [];

    //Load sessions from shared prefs
    try {
      sessions = ref.read(untisSessionsProvider);
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while parsing session json", error: e, stackTrace: s);
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

    //Load data from untis
    setState(() {
      _message = "Refreshing session";
    });
    final connectivityResult = await ref.read(connectivityProvider.future);
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await refreshSession(ref, sessions.first as ActiveUntisSession);
      } on RPCError catch (e, s) {
        await _onRPCError(sessions, e, s);
        return;
      } on (SocketException, TimeoutException) {
        setState(() {
          _message = "No internet connection, using cached data";
        });
      }
    } else {
      setState(() {
        _message = "No internet connection, using cached data";
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
    );
  }

  Future<void> _onRPCError(List<UntisSession> sessions, RPCError e, StackTrace s) async {
    switch (e.code) {
      case RPCError.invalidClientTime:
        setState(() {
          _message = "Invalid client time, please check your system time";
        });
        break;
      case RPCError.authenticationFailed:
        getLogger().w("Bad credentials, reauthenticating");
        setState(() {
          _message = "Bad credentials, reauthenticating";
        });
        var session = sessions.first;
        var newSession = UntisSession.inactive(
          username: session.username,
          password: session.password,
          school: session.school,
        );
        try {
          //Trying to reauthenticate
          ref.read(untisSessionsProvider.notifier).updateSession(session, await activateSession(ref, newSession));
        } on RPCError catch (e) {
          //Reauthentication failed, deleting session
          if (e.code == RPCError.authenticationFailed) {
            setState(() {
              _message = "Bad credentials, deleting session";
            });
            getLogger().w("Bad credentials, deleting session");
            ref.read(untisSessionsProvider.notifier).removeSession(session);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("Deine Anmeldedaten sind ungültig, bitte melde dich erneut an.", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
            ),
          );
          return;
        } catch (e) {
          //An unknown error occurred while reauthenticating
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
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ),
        );
    }
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
