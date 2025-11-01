import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:your_schedule/ui/screens/login_screen/widgets/qr_code_scanner.dart';
import 'package:your_schedule/util/logger.dart';

class ScanQrCodeScreen extends ConsumerStatefulWidget {
  const ScanQrCodeScreen({super.key});

  @override
  ConsumerState createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends ConsumerState<ScanQrCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'QR-Code scannen',
                        style: Theme.of(context).textTheme
                            .headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: QRCodeScanner(
                          onScan: onScan,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: lock ? 1 : 0,
                        child: const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: const Text("Zurück"),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool lock = false;

  Future<void> onScan(Barcode barcode) async {
    if (lock) {
      return;
    }
    setState(() {
      lock = true;
    });

    if (await Vibration.hasVibrator()) {
      getLogger().i("Vibrating");
      await Vibration.vibrate(amplitude: 64, duration: 32);
    }

    await attemptLogin(barcode);

    if (mounted) {
      setState(() {
        lock = false;
      });
    }
  }

  Future<void> attemptLogin(Barcode barcode) async {
    getLogger().i("attempting login");
    await Future.delayed(Duration(seconds: 5));
  }
}

