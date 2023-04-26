import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_schedule/filter/filter.dart';
import 'package:your_schedule/settings/custom_subject_color/custom_subject_color_provider.dart';

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
    //Initialisierung der Provider
    ref.read(filterItemsProvider.notifier).initialize();
    ref.read(customSubjectColorProvider.notifier).initialize();

    //TODO
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
