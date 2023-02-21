import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/core/exceptions.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/settings/custom_subject_color/custom_subject_color_provider.dart';
import 'package:your_schedule/ui/screens/filter_screen/filter_screen.dart';
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

  //Hier wird der login mit gespeicherten Daten versucht
  Future<void> login() async {
    ref.read(filterItemsProvider.notifier).initialize();
    ref.read(customSubjectColorProvider.notifier).initialize();

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
      // Weil wir den BuildContext nicht speichern, ist die Nutzung hier kein Problem
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
    if (ref.read(filterItemsProvider).isEmpty) {
      ref.read(filterItemsProvider.notifier).filterEverything(
            ref.read(timeTableProvider).weekData.values.toList(),
          );
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FilterScreen()),
      );
      return;
    }
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
