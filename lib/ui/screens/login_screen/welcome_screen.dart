import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:your_schedule/core/provider/connectivity_provider.dart';
import 'package:your_schedule/core/rpc_request/rpc.dart';
import 'package:your_schedule/core/untis.dart';
import 'package:your_schedule/ui/screens/login_screen/login_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/manual_login_screen.dart';
import 'package:your_schedule/ui/screens/login_screen/widgets/qr_code_scanner.dart';
import 'package:your_schedule/ui/screens/login_screen/widgets/welcome_widget.dart';
import 'package:your_schedule/utils.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool doSearchSchool = false;
  List<School> possibleSchools = [];
  String? errorMessage;
  String? helperMessage;

  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    Future<List<ConnectivityResult>> connectivity = ref.watch(connectivityProvider.future);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Untis Connect"),
          centerTitle: true,
          leading: doSearchSchool ? IconButton(
            onPressed: () {
              node.unfocus();
              setState(() {
                doSearchSchool = false;
                possibleSchools = [];
              });
            },
            icon: const Icon(Icons.arrow_back),
          ) : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: doSearchSchool ? ListView(
                      children: [
                        for (var school in possibleSchools)
                          ListTile(
                            title: Text(school.displayName),
                            subtitle: Text(school.address),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen(school: school)),
                              );
                            },
                          )
                      ],
                    ) : const WelcomeWidget(),
                  ),
                ),
                //Spacer(),
                TextField(
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.fullStreetAddress,
                  ],
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    helperText: helperMessage,
                    hintText: "Schulname oder Adresse",
                    errorText: errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () => setState(() {
                    doSearchSchool = true;
                  }),
                  onChanged: (s) => _onTextChanged(s, connectivity),
                  focusNode: node,
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !doSearchSchool ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: qrCodePressed,
                          icon: const Icon(Icons.qr_code),
                          label: const Text("QR-Code"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: manualLoginPressed,
                          child: const Text("Manueller Log-In"),
                        ),
                      ),
                    ],
                  ) : Container(),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<void> _onTextChanged(String s, Future<List<ConnectivityResult>> connectivity) async {
    if (s.isEmpty) {
      setState(() {
        possibleSchools = [];
        helperMessage = null;
        errorMessage = null;
      });
      return;
    }

    if (s.length < 3) {
      setState(() {
        possibleSchools = [];
        helperMessage = "Gib mindestens 3 Zeichen ein";
        errorMessage = null;
      });
      return;
    }

    var connectivityResult = await connectivity;
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        errorMessage = "Keine Internetverbindung";
      });
      return;
    }

    try {
      var schools = await ref.read(requestSchoolListProvider(s).future);
      if (schools.isEmpty) {
        setState(() {
          possibleSchools = schools;
          errorMessage = "Keine Ergebnisse";
          helperMessage = null;
        });
      } else {
        setState(() {
          possibleSchools = schools;
          errorMessage = null;
          helperMessage = null;
        });
      }
    } on RPCError catch (e, s) {
      if (e.code == RPCError.tooManyResults) {
        setState(() {
          helperMessage = "Zu viele Ergebnisse, bitte gib etwas genauers ein!";
          errorMessage = null;
        });
        return;
      }
      logRequestError("Error while requesting school list", e, s);
      setState(() {
        errorMessage = e.message;
      });
    } on ClientException catch (e, s) {
      logRequestError("ClientException while requesting school list", e, s);
      setState(() {
        errorMessage = e.message;
      });
    } catch (e, s) {
      logRequestError("Unknown error while requesting school list", e, s);
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> qrCodePressed() async {
    Barcode? barcode = await showScanDialog(context);
    getLogger().i(barcode?.displayValue);
  }

  void manualLoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManualLoginScreen()),
    );
  }
}
