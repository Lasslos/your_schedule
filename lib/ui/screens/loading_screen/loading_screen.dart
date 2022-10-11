import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/ui/screens/home_screen/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/util/logger.dart';
import 'package:your_schedule/util/secure_storage_util.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  String _message = "Logging in";
  bool _showTryAgain = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      login();
    });
  }

  Future<void> login() async {
    try {
      await ref.read(userSessionProvider.notifier).createSession(
            await secureStorage.read(key: usernameKey) ?? "",
            await secureStorage.read(key: passwordKey) ?? "",
            await secureStorage.read(key: schoolKey) ?? "",
            await secureStorage.read(key: apiBaseURlKey) ?? "",
          );
    } on MissingCredentialsException {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(message: ""),
        ),
      );
      return;
    } catch (e, s) {
      getLogger().e("Error while creating session", e, s);
      // This can be ignored as we use the context given by the state, meaning we don't store it.
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(message: e.toString()),
        ),
      );
      return;
    }
    setState(() {
      _message = "Loading period schedule";
    });
    try {
      await ref.read(periodScheduleProvider.notifier).loadPeriodSchedule();
    } catch (e, s) {
      setState(() {
        _message = e.toString();
        _showTryAgain = true;
      });
      getLogger().e("Error while fetching period schedule", e, s);
      return;
    }
    setState(() {
      _message = "Loading your timetable";
    });
    try {
      await ref
          .read(timeTableProvider.notifier)
          .fetchTimeTableWeek(Week.relativeToCurrentWeek(0));
    } catch (e, s) {
      setState(() {
        _message = e.toString();
        _showTryAgain = true;
      });
      getLogger().e("Error while fetching timetable", e, s);
    }
    setState(() {
      _message = "Done";
    });
    await Future.delayed(const Duration(milliseconds: 500));
    // This can be ignored as we use the context given by the state, meaning we don't store it.
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
            const SizedBox(
              height: 200,
              child: AspectRatio(
                aspectRatio: 1,
                child: Placeholder(
                  child: Center(
                    child: Text("Logo"),
                  ),
                ),
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
