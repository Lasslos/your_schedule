import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_schedule/core/api/models/helpers/timetable_week.dart';
import 'package:your_schedule/core/api/providers/period_schedule_provider.dart';
import 'package:your_schedule/core/api/providers/timetable_provider.dart';
import 'package:your_schedule/core/api/providers/user_session_provider.dart';
import 'package:your_schedule/ui/screens/home_screen.dart';
import 'package:your_schedule/ui/screens/login_screen.dart';
import 'package:your_schedule/util/logger.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  String _message = "";
  bool _showTryAgain = false;

  @override
  void initState() {
    super.initState();
    login();
  }

  Future<void> login() async {
    try {
      await ref.read(userSessionProvider.notifier).createSession(
          "Q1",
          "!CjdQ1**",
          "cjd-königswinter" //await secureStorage.read(key: usernameKey) ?? "",
          //await secureStorage.read(key: passwordKey) ?? "",
          );
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
      getLogger().e(e);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }
    setState(() {
      _message = "Loading period schedule";
    });
    try {
      await ref.read(periodScheduleProvider.notifier).loadPeriodSchedule();
    } catch (e) {
      setState(() {
        _message = e.toString();
        _showTryAgain = true;
      });
      getLogger().e(e);
      return;
    }
    setState(() {
      _message = "Loading your timetable";
    });
    try {
      await ref
          .read(timeTableProvider.notifier)
          .getTimeTableWeek(Week.relativeToCurrentWeek(0));
    } catch (e) {
      setState(() {
        _message = e.toString();
        _showTryAgain = true;
      });
      getLogger().e(e);
      rethrow;
    }
    setState(() {
      _message = "Done";
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Text(_message),
          const Spacer(flex: 1),
          if (_showTryAgain)
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text("Try again"),
            ),
          if (!_showTryAgain) const CircularProgressIndicator(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
