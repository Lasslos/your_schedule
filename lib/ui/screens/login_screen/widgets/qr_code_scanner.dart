import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:your_schedule/util/logger.dart';

class QRCodeScanner extends ConsumerStatefulWidget {
  const QRCodeScanner({required this.onScan, super.key});

  final void Function(Barcode) onScan;

  @override
  ConsumerState<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends ConsumerState<QRCodeScanner> {
  static bool torchEnabled = false;
  static CameraFacing cameraFacing = CameraFacing.back;

  MobileScannerController cameraController = MobileScannerController(
    detectionTimeoutMs: 500,
    torchEnabled: torchEnabled,
    facing: cameraFacing,
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 300,
        width: 300,

        child: Stack(
          children: [
            MobileScanner(
              // fit: BoxFit.contain,
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  getLogger().i("Barcode found: ${barcode.rawValue}");
                  widget.onScan(barcode);
                }
              },
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController,
                      builder: (context, state, child) {
                        switch (state.torchState) {
                          case TorchState.off:
                          case TorchState.unavailable:
                            return const Icon(Icons.flash_off, color: Colors.grey);
                          case TorchState.on:
                            return const Icon(Icons.flash_on, color: Colors.yellow);
                          case TorchState.auto:
                            throw UnimplementedError();
                        }
                      },
                    ),
                    iconSize: 32.0,
                    onPressed: () {
                      cameraController.toggleTorch();
                      torchEnabled = !torchEnabled;
                    },
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController,
                      builder: (context, state, child) {
                        switch (state.cameraDirection) {
                          case CameraFacing.front:
                            return const Icon(Icons.camera_front);
                          case CameraFacing.back:
                            return const Icon(Icons.camera_rear);
                          case CameraFacing.external:
                          case CameraFacing.unknown:
                            return const Icon(Icons.question_mark);
                        }
                      },
                    ),
                    iconSize: 32.0,
                    onPressed: () {
                      cameraController.switchCamera();
                      cameraFacing = cameraFacing == CameraFacing.back ? CameraFacing.front : CameraFacing.back;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
