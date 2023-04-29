//ignore_for_file: use_build_context_synchronously
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:your_schedule/core/session/custom_subject_colors.dart';
import 'package:your_schedule/core/session/filters.dart';
import 'package:your_schedule/core/session/session.dart';
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
  bool _showTryAgain = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      login();
    });
  }

  //Hier wird der login mit gespeicherten Daten versucht
  Future<void> login() async {
    List<Session> sessions = [];
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

    try {
      await ref.read(filtersProvider.notifier).initializeFromPrefs();
      await ref
          .read(customSubjectColorsProvider.notifier)
          .initializeFromPrefs();
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while parsing json", e, s);
    }

    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      activateSession(ref, sessions.first);
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
            if (_showTryAgain)
              ElevatedButton(
                onPressed: () {
                  login();
                },
                child: const Text("Try again"),
              ),
            if (!_showTryAgain) const CircularProgressIndicator(),
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
