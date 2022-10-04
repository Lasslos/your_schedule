import 'package:flutter/material.dart';

class PinchToZoom extends StatefulWidget {
  const PinchToZoom({required this.child, this.initialSize = 300, super.key});

  final double initialSize;
  final Widget child;

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom> {
  late double size;
  double? onScaleStartSize;

  @override
  void initState() {
    super.initState();
    size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          onScaleStartSize = size;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            size = onScaleStartSize! * details.verticalScale;
          });
        },
        onScaleEnd: (_) {
          onScaleStartSize = null;
        },
        child: SizedBox(
          height: size,
          child: widget.child,
        ),
      );
}
